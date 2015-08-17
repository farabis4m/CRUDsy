//
//  AuthorsViewController.m
//  CRUDsy
//
//  Created by vlad gorbenko on 8/17/15.
//  Copyright (c) 2015 vlad gorbenko. All rights reserved.
//

#import "AuthorsViewController.h"
#import "BooksViewController.h"

#import "Author.h"

#import "NSObject+JSON.h"

#import "APIJSONAdapter.h"

#import <MagicalRecord/NSManagedObject+MagicalRecord.h>

@interface AuthorsViewController ()

@property (nonatomic, strong) NSArray *authors;

@end

@implementation AuthorsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"authors" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSArray *authorsJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSError *error = nil;
    NSMutableArray *authros = [[NSMutableArray alloc] initWithCapacity:authorsJSON.count];
    for(NSDictionary *authorJSON in authorsJSON) {
        Author *author = [APIJSONAdapter modelOfClass:[Author class] fromJSONDictionary:authorJSON action:@"index" error:&error];
        [authros addObject:author];
    }

    self.authors = authros;
    
    self.clearsSelectionOnViewWillAppear = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.authors.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AuthorTableViewCell" forIndexPath:indexPath];
    Author *author = self.authors[indexPath.row];
    cell.textLabel.text = [author fullname];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", author.books.count];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.destinationViewController isKindOfClass:[BooksViewController class]]) {
        BooksViewController *booksViewController = segue.destinationViewController;
        NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
        booksViewController.author = self.authors[selectedIndexPath.row];
    }
}

@end
