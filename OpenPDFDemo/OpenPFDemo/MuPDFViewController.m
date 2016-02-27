//
//  MuPDFViewController.m
//  OpenPFDemo
//
//  Created by coverme on 16/2/26.
//  Copyright © 2016年 Kangqj. All rights reserved.
//

#import "MuPDFViewController.h"
#include "common.h"
#include "mupdf/fitz.h"
#import "MuDocRef.h"
#import "MuDocumentController.h"

@interface MuPDFViewController ()
{
    char *_filePath;
    NSString *_filename;
    
    fz_context *ctx;
    MuDocRef *doc;
}

@end

@implementation MuPDFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"pdf"];
    
    [self openPDF:path name:@"test.pdf"];
}

- (void)openPDF:(NSString *)path name:(NSString *)name
{
    _filePath = malloc(strlen([path UTF8String])+1);
    
    strcpy(_filePath, [path UTF8String]);
    
    dispatch_sync(queue, ^{});
    
    printf("open document '%s'\n", _filePath);
    
    _filename = [name retain];
    
    doc = [[MuDocRef alloc] initWithFilename:_filePath];
    if (!doc) {
        
        return;
    }
    
    if (fz_needs_password(ctx, doc->doc))
    {
        [self askForPassword: @"'%@' needs a password:"];
    }
    else
    {
        [self onPasswordOkay];
    }
}

- (void)askForPassword: (NSString*)prompt
{
    UIAlertView *passwordAlertView = [[UIAlertView alloc]
                                      initWithTitle: @"Password Protected"
                                      message: [NSString stringWithFormat: prompt, [_filename lastPathComponent]]
                                      delegate: self
                                      cancelButtonTitle: @"Cancel"
                                      otherButtonTitles: @"Done", nil];
    [passwordAlertView setAlertViewStyle: UIAlertViewStyleSecureTextInput];
    [passwordAlertView show];
    [passwordAlertView release];
}

- (void)onPasswordOkay
{
    MuDocumentController *document = [[MuDocumentController alloc] initWithFilename:_filename path:_filePath document:doc];
    if (document) {
        [self setTitle: @"Library"];
        [[self navigationController] pushViewController:document animated:YES];
        [document release];
    }
    [_filename release];
    free(_filePath);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
