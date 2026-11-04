// § dirlessFormalTypeAtName155
package pk; typedef enum logic [1:0] {A, B} e_t; endpackage
module top (input logic [3:0] i, output int x);
  task automatic t(pk::e_t [1:0] v, output int r); r = int'(v); endtask
  always_comb t(pk::e_t'(i), x);
endmodule
