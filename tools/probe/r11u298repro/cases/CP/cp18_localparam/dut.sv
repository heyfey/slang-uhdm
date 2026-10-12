// § castClsTpOwnDefaultObj298
// constant slot: a cast in a class localparam initializer and a replication count
package p;
  class gen #(type U = logic [7:0]);
    localparam int K = U'(3);
    logic [15:0] y;
    function void f(); y = {U'(K){2'b01}}; endfunction
  endclass
endpackage
module top; endmodule
