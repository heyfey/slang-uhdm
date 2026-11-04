// § insideSetParamFoldKeepsPa270
package up;
  parameter UVM_SET = 32'h1;
  parameter UVM_GET = 32'h2;
  parameter UVM_CHK = 32'h4;
endpackage
program prg;
  import up::*;
  function automatic bit f(int w);
    return w inside {UVM_SET, UVM_GET};
  endfunction
endprogram
package vp;
  import up::*;
  class item;
    function void auto(int what__);
      if (what__ inside {UVM_SET, UVM_GET, UVM_CHK}) begin
        if (what__ inside {UVM_CHK} && !(what__ inside {UVM_SET})) what__ = 1;
      end
      case (what__) inside
        UVM_SET, UVM_GET: what__ = 2;
      endcase
    endfunction
  endclass
endpackage
module top;
  vp::item i;
endmodule
