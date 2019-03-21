#ifndef MINI_L_H
#define MINI_L_H
#define YY_NO_UNPUT
#include <sstream>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <iostream>
#include <vector>
#include <map>
#include <stack>
#include <string>

using namespace std;

struct airpod{
      string *begin;
      string *parent;
      string *end;
    };

enum Type {INT,INT_ARR,FUNC};

struct Var{
    string *name;
    string *value;
    Type type;
    int length;
    string *index;
};

// map<string, Var> vmap;

struct Terminal{ 
   stringstream *code;
   string *name;
   string *value;
   string *operator1;
   string *begin;
   string *parent;
   string *end;
   Type type;
   int length;
   string *index;
   vector<string> *ids;
   vector<Var> *vars; 
};

#endif