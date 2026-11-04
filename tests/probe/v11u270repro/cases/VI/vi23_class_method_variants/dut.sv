// § insideSetParamFoldKeepsPa270
package up;
  parameter int UVM_SET = 32'h1;
  parameter int UVM_GET = 32'h2;
  parameter int UVM_CHK = 32'h4;
endpackage
package cp;
  import up::*;
  class item;
    int r;
    function void auto(int what__);
      if (what__ inside {UVM_SET, UVM_GET}) r = 1;
      case (what__) inside
        UVM_CHK: r = 2;
        UVM_SET, UVM_GET: r = 3;
      endcase
      r = (what__ inside {[UVM_SET:UVM_CHK]}) ? 4 : 5;
      r = what__ inside {UVM_SET} ? 6 : 7;
      for (int k = 0; k < 2; k++) if (what__ inside {UVM_CHK}) r = 8;
    endfunction
    task t(int w); if (w inside {UVM_GET}) r = 9; endtask
  endclass
endpackage
module top;
  import cp::*;
  item i;
endmodule
