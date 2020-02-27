% Make Test.csv into array, get last two columns
relation = table2array(Test(:,7:8));

% Define which classes interest us
interesting = [0,1,2,3,4,5,7,8,32];

% Find out which rows are we want
yes = ismember(relation(:,1), interesting);

% Get them
relation_interesting = relation(yes,:);

% Define location of Test set
loc = 'E:\BA\Datensatz\Entpackt\Test';

% format numbers to paths to test images we are interested in
paths = strcat(loc, "\", num2str(relation_interesting(:,2), '%05d'), '.png');

% make table of class and path
table = table();
table.class = relation_interesting(:,1);
table.path = paths;

% save table
save('table', 'table');
