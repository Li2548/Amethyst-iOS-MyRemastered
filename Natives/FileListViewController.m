#import "FileListViewController.h"
#import "UIUtils.h"

@interface FileListViewController () {
}

@property(nonatomic) NSMutableArray *fileList;

@end

@implementation FileListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.fileList == nil) {
        self.fileList = [NSMutableArray array];
    } else {
        [self.fileList removeAllObjects];
    }

    // List files
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *files = [fm contentsOfDirectoryAtPath:self.listPath error:nil];
    for(NSString *file in files) {
        NSString *path = [self.listPath stringByAppendingPathComponent:file];
        BOOL isDir = NO;
        [fm fileExistsAtPath:path isDirectory:(&isDir)];
        if(!isDir && [file hasSuffix:@".json"]) {
            [self.fileList addObject:[file stringByDeletingPathExtension]];
        }
    }

    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    // Apply rounded corners to table view
    [UIUtils applyRoundedCorners:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fileList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        // Apply rounded corners to cell
        [UIUtils applyRoundedCorners:cell];
    }

    cell.textLabel.text = [self.fileList objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Apply non-linear animation when selecting a row
    [UIUtils applyNonLinearAnimation:self.view];
    
    [self dismissViewControllerAnimated:YES completion:nil];

    self.whenItemSelected(self.fileList [indexPath.row]);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *str = [self.fileList objectAtIndex:indexPath.row];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *path = [NSString stringWithFormat:@"%@/%@.json", self.listPath, str];
        if (self.whenDelete != nil) {
            self.whenDelete(path);
        }
        [fm removeItemAtPath:path error:nil];
        [self.fileList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
