// § tpUseSharesOwnTs271
package up;
  parameter UVM_SET = 32'h1;
  parameter UVM_GET = 32'h2;
endpackage
module top;
  import up::*;
  function automatic void auto(int what__);
    if (what__ inside {UVM_SET, UVM_GET}) begin
      what__ = 0;
    end
  endfunction
endmodule
