clear all
clc

%define independent variables
constant = [1, 1, 1]';
members = [45, 55, 51]';
bolts = [106, 78, 92]';

%define observations
economy = [1673333, 1790000, 1695000]';

%example multivariate regression:

%just members (Model 1)
X = [members];
Y = economy;
beta = mvregress(X,Y) %the resulting linear coefficients

%constant and members (Model 2)
X = [constant, members];
Y = economy;
beta = mvregress(X,Y) %the resulting linear coefficients

%members and bolts (Model 3)
X = [members, bolts];
Y = economy;
beta = mvregress(X,Y) %the resulting linear coefficients

%fit the data using the surface fit tool (Model 4)
sftool