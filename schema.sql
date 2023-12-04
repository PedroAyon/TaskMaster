drop database if exists task_master;
create database task_master;
use task_master;

create table user
(
    id       int primary key auto_increment,
    name     varchar(100) not null,
    email    varchar(50)  not null unique,
    password varchar(255) not null
);

create table workspace
(
    id        int primary key auto_increment,
    name      varchar(100),
    createdBy int,
    foreign key (createdBy) references user (id)
);

create table member
(
    userId      int,
    workspaceId int,
    role        enum ('Admin', 'Normal'),
    foreign key (userId) references user (id) on delete cascade,
    foreign key (workspaceId) references workspace (id) on delete cascade,
    primary key (userId, workspaceId)
);

create table board
(
    id          int primary key auto_increment,
    workspaceId int not null,
    name        varchar(100) unique,
    foreign key (workspaceId) references workspace (id) on delete cascade
);

create table board_list
(
    id      int primary key auto_increment,
    name    varchar(100) not null,
    boardId int          not null,
    foreign key (boardId) references board (id) on delete cascade
);

create table task
(
    id          int primary key auto_increment,
    listId      int          not null,
    title       varchar(100) not null,
    description JSON,
    dueDate     DATE,
    foreign key (listId) references board_list (id) on delete cascade
);

create table assigned_tasks
(
    userId      int,
    workspaceId int,
    taskId      int,
    foreign key (userId, workspaceId) references member (userId, workspaceId) on delete cascade,
    foreign key (taskId) references task (id) on delete cascade,
    primary key (userId, workspaceId, taskId)
);

create table checklist_item
(
    taskId      int,
    itemNumber  int,
    completed   bool,
    description TEXT,
    foreign key (taskId) references task (id) on delete cascade,
    primary key (taskId, itemNumber)
);

create table attached_file
(
    taskId   int,
    URL      varchar(255),
    fileName varchar(255),
    foreign key (taskId) references task (id) on delete cascade,
    primary key (taskId, URL)
);
