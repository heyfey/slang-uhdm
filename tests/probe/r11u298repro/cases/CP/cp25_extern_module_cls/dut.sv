// § castClsTpOutOfBodyPlaceholder298
// an extern task body in a class of a package, a typedef default and a vector default
package p;
  typedef logic [3:0] n_t;
  class gen #(type U = logic [7:0], type V = bit [2:0]);
    int y;
    extern task t();
  endclass
  task gen::t(); y = U'(3); y = V'(1); endtask
endpackage
module top; endmodule
