// § castClsTpOwnDefaultObj298
// a class specialization's static method called in a module part-select bound
package p;
  class gen #(type U = logic [7:0]);
    static function int w(); return U'(3); endfunction
  endclass
endpackage
module top (input logic [7:0] a, output logic [7:0] y);
  assign y = 8'(a[p::gen#(logic [3:0])::w():0]);
endmodule
