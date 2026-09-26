// § ppFileCallArgBody168 § ppOutputFile166
`include "trace.svh"
class ph;
  function string get_full_name(); return "x"; endfunction
  function int get_inst_id(); return 1; endfunction
  function int en(int v, string s); return 1; endfunction
  function void rpt(string a, string b, int c, string d, int e); endfunction
  function void run();
    if (1) begin
      `TOP(this)
    end
  endfunction
endclass
module top;
  ph p = new;
endmodule
