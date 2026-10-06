// § procReplCountOwner254 (a class method in a module, the constant slots: part-select bounds beside the count, an indexed width, a sized cast)
package pk;
  parameter int N = 3;
endpackage
module top;
  import pk::*;
  class c;
    function logic [5:0] f(); return {N{2'b10}}; endfunction
  endclass
  logic [7:0] q;
  always_comb begin : nb
    q[5:0] = {N{2'b10}};
    q[0 +: 6] = {N{2'b01}};
    q = 8'({N{2'b11}});
  end
endmodule
