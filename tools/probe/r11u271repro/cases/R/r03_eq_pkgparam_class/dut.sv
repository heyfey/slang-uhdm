// § tpUseSharesOwnTs271
package up;
  parameter UVM_SET = 32'h1;
  parameter UVM_GET = 32'h2;
endpackage
package vp;
  import up::*;
  class item;
    function void auto(int what__);
      if (what__ == UVM_SET) begin
        what__ = 0;
      end
    endfunction
  endclass
endpackage
module top;
  vp::item i;
endmodule
