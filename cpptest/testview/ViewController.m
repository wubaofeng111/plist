//
//  ViewController.m
//  testview
//
//  Created by friday on 2019/8/30.
//  Copyright © 2019 friday. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>
#import "ProcessVideoViewController.h"
#import "BFAVPlayerViewController.h"
#import "SimpleVideoFileFilterViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSFileManager *defaultManager;
    NSArray       *rootFiles;
    NSString      *reuseId;
    
    __weak IBOutlet UILabel *tips;
}
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property(nonatomic,retain) NSString *curentPath;
@property(nonatomic,retain) NSString *selectFile;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    ///
    
    NSCoder *coder = [[NSCoder alloc]init];
    
    UIButton *btn;
    [btn actionsForTarget:nil forControlEvent:64];
    
    _mTableView.delegate = self;
    _mTableView.dataSource = self;
    
    defaultManager = [NSFileManager defaultManager];
    reuseId = @"reuseId";
    if (_curentPath == nil) {
        
        _curentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        
        
    }else{
        
    }
    
   rootFiles = [defaultManager subpathsOfDirectoryAtPath:_curentPath error:nil];
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:reuseId];
    }
    cell.textLabel.text = [rootFiles objectAtIndex:indexPath.row];
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return rootFiles.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *string = [rootFiles objectAtIndex:indexPath.row];
    _selectFile = [_curentPath stringByAppendingPathComponent:string];
    
}
- (IBAction)next:(id)sender {
    
    [[NSFileManager defaultManager] removeItemAtPath:_selectFile error:nil];
    rootFiles = [defaultManager subpathsAtPath:_curentPath];
    [_mTableView reloadData];
    return;
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:_selectFile isDirectory:&isDirectory];
    
    if (isDirectory) {
        ViewController *view = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ViewController"];
        view.curentPath = _selectFile;
        [self.navigationController pushViewController:view animated:YES];
    }
}
- (IBAction)savew:(id)sender {
    
    if ([_selectFile hasSuffix:@".mp4"]) {
        UISaveVideoAtPathToSavedPhotosAlbum(_selectFile, self, @selector(SaveVideoPhotoImage:DidFinishSavingWithError:ContextInfo:), nil);
    }else if([_selectFile hasSuffix:@".png"]||[_selectFile hasSuffix:@".jpg"]){
        UIImage *image = [[UIImage alloc]initWithContentsOfFile:_selectFile];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(SaveVideoPhotoImage:DidFinishSavingWithError:ContextInfo:), nil);
    }else{
        [self tipMsg:@"不支持的文件类型"];
    }
    
    
}

-(void)SaveVideoPhotoImage:(UIImage*)img DidFinishSavingWithError:(NSError**)error ContextInfo:(NSDictionary*)info
{
    if (error == nil) {
        [self tipMsg:@"保存成功"];
    }else{
        [self tipMsg:@"发送错误"];
    }
}

-(void)tipMsg:(NSString*)msg
{
    tips.text = msg;
    [tips performSelector:@selector(setText:) withObject:@"" afterDelay:1.2];
    
    
}

- (IBAction)reloadView:(id)sender {
    NSLog(@"%@",NSHomeDirectory());
     rootFiles = [defaultManager subpathsAtPath:_curentPath];
    [_mTableView reloadData];
}

-(IBAction)speVideoTime
{
    ProcessVideoViewController *viewControllr = [[ProcessVideoViewController alloc]init];
    viewControllr.filePath = _selectFile;
    [self.navigationController pushViewController:viewControllr animated:YES];
}
- (IBAction)play:(id)sender {
    SimpleVideoFileFilterViewController *player = [[SimpleVideoFileFilterViewController alloc]init];
    player.videoPath = _selectFile;
    [self.navigationController pushViewController:player animated:YES];
}



@end
