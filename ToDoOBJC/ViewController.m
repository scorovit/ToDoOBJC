//
//  ViewController.m
//  ToDoOBJC
//
//  Created by Sergey Guznin on 29.01.17.
//  Copyright © 2017 Sergey Guznin. All rights reserved.
//

#import "ViewController.h"
#import "ToDo.h"
#import "DetailViewController.h"
#import "Cell.h"

@interface ViewController ()

@end

@implementation ViewController
-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
  [self reloadToDoItems];
  NSLog(@"%d", self.toDoes.count);
}
- (void)reloadToDoItems {
  self.toDoes = [ToDo loadData];
  [self.tableView reloadData];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  NSData *todoData = [[NSUserDefaults standardUserDefaults] objectForKey:@"todo"];
  self.toDoes = [[NSKeyedUnarchiver unarchiveObjectWithData:todoData] mutableCopy];
}

  - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
  }
  -(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.toDoes.count;
  }
  -(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Cell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    int index = [indexPath row];
    ToDo *toDo = self.toDoes[index];
    cell.textLabel.text = toDo.name;
    if(toDo.isDone) {
      cell.image.image = [UIImage imageNamed:@"check"];
    } else {
      cell.image.image = [UIImage imageNamed:@"uncheck"];
    }
    // Add tap recognizer to Image
    
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tappedCheck:)];
    
    tapGesture1.numberOfTapsRequired = 1;
    
    [tapGesture1 setDelegate:self];
    
    [cell.image addGestureRecognizer:tapGesture1];
    cell.image.userInteractionEnabled = YES;
    cell.image.tag = indexPath.row;
    return cell;
  }
  -(void)tappedCheck:(UITapGestureRecognizer *)tap{
    int tag = tap.view.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tag inSection:0];
    [self.toDoes[indexPath.row] changeStatus];
    [ToDo saveDataWithArray:self.toDoes];
    [self.tableView reloadData];
    
  }
  -(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath     *)indexPath
  {
    [self performSegueWithIdentifier:@"AddToDo" sender:self];
    
  }

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewRowAction *deleteAction = [UITableViewRowAction
                                        rowActionWithStyle:UITableViewRowActionStyleDefault
                                        title:@"Delete"
                                        handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                          [self deleteItemForIndexPath:indexPath fromTableView:tableView];
                                        }];
  deleteAction.backgroundColor = [UIColor redColor];
  
  return @[deleteAction];
}

- (void)deleteItemForIndexPath:(NSIndexPath *)indexPath fromTableView:(UITableView *)tableView  {
   [self.toDoes removeObjectAtIndex: indexPath.row];
   [ToDo saveDataWithArray:self.toDoes];
   [self.tableView reloadData];
}

  -(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([@"AddToDo" isEqualToString:[segue identifier]]) {
      UINavigationController *navigtionController = [segue destinationViewController];
      DetailViewController *detailViewController = [navigtionController viewControllers][0];
      // Get the cell that generated this segue.
      NSIndexPath *indexpath = nil;
      indexpath = [self.tableView indexPathForSelectedRow];
      detailViewController.toDo = self.toDoes[indexpath.row] ;
      detailViewController.viewList = self;
      detailViewController.index = indexpath.row;
      
    }
  
  }
  
- (IBAction)Menu:(id)sender {
  UIAlertController * alert=   [UIAlertController
                                alertControllerWithTitle: @"Menu"
                                message: @"Sort content by"
                                preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction* abcSort = [UIAlertAction
                             actionWithTitle:@"ABC"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                               [self sortABC];
                             }];
  UIAlertAction* dateSort = [UIAlertAction
                            actionWithTitle:@"Date"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                              [self sortDate];
                            }];
  UIAlertAction* cancel = [UIAlertAction
                            actionWithTitle:@"Cancel"
                            style:UIAlertActionStyleCancel
                            handler:^(UIAlertAction * action)
                            {
                            }];
  [alert addAction:abcSort];
  [alert addAction:dateSort];
  [alert addAction:cancel];
  [self presentViewController:alert animated:YES completion: nil];
}
-(void)sortABC{
  NSSortDescriptor *sortDescriptor =
  [NSSortDescriptor sortDescriptorWithKey:@"name"
                                ascending:YES
                                 selector:@selector(caseInsensitiveCompare:)];
  NSArray *sortedArray = [self.toDoes sortedArrayUsingDescriptors:@[sortDescriptor]];
  self.toDoes = sortedArray;
  [self.tableView reloadData];
  
}
  
  -(void)sortDate{
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor
                                        sortDescriptorWithKey:@"date"
                                        ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
    NSArray *sortedArray = [self.toDoes
                                 sortedArrayUsingDescriptors:sortDescriptors];
    
    self.toDoes = sortedArray;
    [self.tableView reloadData];
    
  }
@end
