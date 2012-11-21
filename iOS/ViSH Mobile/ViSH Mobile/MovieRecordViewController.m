//
//  ViewController.m
//  ViSH Mobile
//
//  Created by Santiago Pavón on 19/11/12.
//  Copyright (c) 2012 UPM. All rights reserved.
//

#import "MovieRecordViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
//#import <MobileCoreServices/MobileCoreServices.h>


@interface MovieRecordViewController ()
<AVCaptureVideoDataOutputSampleBufferDelegate,


AVCaptureAudioDataOutputSampleBufferDelegate,
AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession *_session;
    
    CIContext *_coreImageContext;
    EAGLContext *_context;
    
    
    IBOutlet GLKView *_glkView;
    
    AVAssetWriter *_assetWriter;
    AVAssetWriterInput *_assetWriterAudioInput;
    AVAssetWriterInputPixelBufferAdaptor *_assetWriterPixelBufferInput;
    BOOL _isWriting;
    CMTime currentSampleTime;
    
 
    
}
@end

@implementation MovieRecordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    // Usar OpenGL para la view que muestra la camara.
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_context) {
        NSLog(@"Failed to create ES context");
    }
    _glkView.context = _context;
    float screenWidth = [[UIScreen mainScreen] bounds].size.height;
    _glkView.contentScaleFactor = 640.0 / screenWidth;
    _coreImageContext = [CIContext contextWithEAGLContext:_context];
    
    
    // Crear la sesion de captura
    _session = [[AVCaptureSession alloc] init];
    
    [_session beginConfiguration];
    
    // Capturaremos a 640x480
    if ([_session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        [_session setSessionPreset:AVCaptureSessionPreset640x480];
    }
    
    // Buscar camara trasera
    NSArray *devices = [AVCaptureDevice devices];
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *d in devices) {
        if (d.position == AVCaptureDevicePositionBack &&
            [d hasMediaType:AVMediaTypeVideo]) {
            videoDevice = d;
            break;
        }
    }
    
    // Añadir la camara como entrada de ls sesion
    NSError *err;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice
                                                                             error:&err];
    [_session addInput:videoInput];
    
    
    // Añadir el microfono como entrada de Audio a la sesion
    AVCaptureDevice *mic = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:mic error:&err];
    if (err) {
        NSLog(@"Video Device Error %@", [err localizedDescription]);
    }
    [_session addInput:audioDeviceInput];
    
    // El audio capturado se envia para su procesamiento
    AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [audioOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:audioOutput];
    
    
    // El video capturado se envia para su procesamiento
    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [videoOutput setAlwaysDiscardsLateVideoFrames:YES];
    [videoOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)}];
    [videoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:videoOutput];
    
    
    // Se termino de configurar la sesion
    [_session commitConfiguration];
    
    
    // Escribir ficheros
    
    _isWriting = NO;

}


-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [_session startRunning];
}

-(void)viewWillDisappear:(BOOL)animated
{
        [_session stopRunning];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) captureOutput:(AVCaptureOutput *)captureOutput
 didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
        fromConnection:(AVCaptureConnection *)connection
{
    NSString *outputClass = NSStringFromClass([captureOutput class]);
    
    if ([outputClass isEqualToString:@"AVCaptureAudioDataOutput"]) {
        
        // Salvando a fichero
        if (_isWriting && _assetWriterAudioInput.isReadyForMoreMediaData) {
            BOOL succ = [_assetWriterAudioInput appendSampleBuffer:sampleBuffer];
            if (!succ) {
                NSLog(@"audio buffer not appended");
            }
        }
        
    } else {
        
        CVPixelBufferRef pixelBuffer = (CVPixelBufferRef) CMSampleBufferGetImageBuffer(sampleBuffer);
        
        // int width = CVPixelBufferGetWidth(pixelBuffer);
        // int height = CVPixelBufferGetHeight(pixelBuffer);
        // NSLog(@"got sample buffer, width %d, height %d", width, height);
        
        CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
        
        // Girar la imagen si es necesario
        if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
            image = [image imageByApplyingTransform:CGAffineTransformMakeRotation(M_PI)];
            image = [image imageByApplyingTransform:CGAffineTransformMakeTranslation(640.0, 480.0)];
        }
        
        
        currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);
        
        // Salvando a fichero
        if (_isWriting && _assetWriterPixelBufferInput.assetWriterInput.isReadyForMoreMediaData) {
            
            CVPixelBufferRef newPixelBuffer = NULL;
            CVPixelBufferPoolCreatePixelBuffer(NULL,
                                               [_assetWriterPixelBufferInput pixelBufferPool],
                                               &newPixelBuffer);
            
            [_coreImageContext render:image
                      toCVPixelBuffer:newPixelBuffer
                               bounds:CGRectMake(0, 0, 640, 480)
                           colorSpace:NULL];
            
            if (newPixelBuffer) {
                
                BOOL success = [_assetWriterPixelBufferInput appendPixelBuffer:newPixelBuffer
                                                          withPresentationTime:currentSampleTime];
                
                if (!success) {
                    NSLog(@"Pixel Buffer not appended");
                }
                
                CVPixelBufferRelease(newPixelBuffer);
            }
        }
        
        // Pinta el frame en la pantalla:
        
        [_coreImageContext drawImage:image inRect:[image extent] fromRect:[image extent]];
        
        [_context presentRenderbuffer:GL_RENDERBUFFER ];
    }
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}


-(NSURL *)movieURL {
    
    NSString *tempDir = NSTemporaryDirectory();
    NSString *urlString = [tempDir stringByAppendingPathComponent:@"tmpMov3.mov"];
    return [NSURL fileURLWithPath:urlString];
}


-(void) checkForAndDeleteFile {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSURL * url = [self movieURL];
    
    NSLog(@"Movie TMP url: %@", url);
    
    NSError *err;
    [fm removeItemAtURL:url error:&err];
    if (err) {
        NSLog(@"file remove error, %@", err.localizedDescription );
    }
    
}

-(void)createWriter {
    
    [self checkForAndDeleteFile];
    
    NSError *error;
    _assetWriter = [[AVAssetWriter alloc] initWithURL:[self movieURL]
                                             fileType:AVFileTypeQuickTimeMovie
                                                error:&error];
    if (error) {
        NSLog(@"Couldn't create writer, %@",
              error.localizedDescription);
        return;
    }
    
    _assetWriter.shouldOptimizeForNetworkUse = YES;
    
    NSDictionary *outputSettings = @{
    AVVideoCodecKey : AVVideoCodecH264,
    AVVideoWidthKey : @640,
    AVVideoHeightKey : @480
    };
    AVAssetWriterInput *assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                                   outputSettings:outputSettings];
    
    assetWriterVideoInput.expectsMediaDataInRealTime = YES;
    
    
    NSDictionary *sourcePixelBufferAttributesDictionary =
    @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
    (id)kCVPixelBufferWidthKey: @640,
    (id)kCVPixelBufferHeightKey: @480};
    _assetWriterPixelBufferInput = [AVAssetWriterInputPixelBufferAdaptor
                                    assetWriterInputPixelBufferAdaptorWithAssetWriterInput:assetWriterVideoInput
                                    sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    
    if ([_assetWriter canAddInput:assetWriterVideoInput]) {
        [_assetWriter addInput:assetWriterVideoInput];
    } else {
        NSLog(@"can't add video writer input %@",
              assetWriterVideoInput);
    }
    
    // Audio
    _assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                                outputSettings:nil];
    if ([_assetWriter canAddInput:_assetWriterAudioInput]) {
        [_assetWriter addInput:_assetWriterAudioInput];
        _assetWriterAudioInput.expectsMediaDataInRealTime = YES;
    } else {
        NSLog(@"can't add audio writer input %@",
              _assetWriterAudioInput);
    }
}


- (IBAction)record:(id)sender {
    
    UIBarButtonItem *button = (UIBarButtonItem *)sender;
    
    if (!_isWriting) {
        [self createWriter];
        button.title = @"Stop";
        
        [_assetWriter startWriting];
        [_assetWriter startSessionAtSourceTime:currentSampleTime];
        
        _isWriting = YES;
    } else {
        _isWriting = NO;
        button.title = @"Record";
        [_assetWriter finishWritingWithCompletionHandler:^{
            [self saveMovieToCameraRoll];
        }];
    }
}




-(void)saveMovieToCameraRoll {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[self movieURL]
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    if (error) {
                                        NSLog(@"Error %@", [error localizedDescription]);
                                    } else {
                                        [self checkForAndDeleteFile];
                                        NSLog(@"Finished saving %@", assetURL);
                                    }
                                }];
}






@end
