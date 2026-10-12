// § castClsTpOutOfBodyPlaceholder298
// an extern constructor and an extern task casting to the type parameter
package p;
  class gen #(type U = logic [7:0]);
    int y;
    extern function new();
    extern task t();
  endclass
  function gen::new(); y = U'(3); endfunction
  task gen::t(); y = U'(4); endtask
endpackage
module top; endmodule
