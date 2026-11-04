// § tfArgTypedefLastWriter146
package p;
typedef enum logic [1:0] {A, B, C} e_t;
task automatic t(input e_t g, output int o);
  o = int'(g);
endtask
endpackage
