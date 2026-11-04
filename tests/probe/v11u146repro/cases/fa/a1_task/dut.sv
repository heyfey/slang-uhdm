// § tfArgTypedefLastWriter146
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  task automatic t1(input e_t x, output logic y);
    y = (x == A);
  endtask
endpackage
module top(output logic o);
  import p::*;
  initial t1(B, o);
endmodule
