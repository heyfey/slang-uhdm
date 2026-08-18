// r10v96 arm 3 — the SAME cast in every HOME.
package v96p3;
  class Cb;
    real m;
    function void inb(logic [15:0] q); m = real'(q); endfunction
    extern function void oob(logic [15:0] q);
    static function void stat(logic [15:0] q); $display("%0d", integer'(q)); endfunction
  endclass
  function void Cb::oob(logic [15:0] q); m = real'(q) + shortreal'(q); endfunction
  function automatic void pfn(logic [15:0] q); $display("%0f", real'(q)); endfunction
  task automatic ptk(logic [15:0] q); $display("%0d", longint'(q)); endtask
endpackage

interface v96if;
  logic [15:0] q;
  function automatic real ifn(); return real'(q); endfunction
  initial $display("%0d", shortint'(q));
endinterface

program v96pg;
  logic [15:0] q;
  initial $display("%0f", real'(q));
endprogram

module v96m3;
  logic [15:0] q;
  real         r;
  function automatic real mfn(); return real'(q); endfunction
  task automatic mtk(); $display("%0d", integer'(q)); endtask
  initial     r = real'(q);
  always_comb r = shortreal'(q);
  always @(*) begin r = time'(q); end
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gb
      localparam int GC = integer'(gi + 1);
      initial $display("%0d %0f", GC, real'(q));
    end
  endgenerate
  v96if u_if();
  initial begin
    v96p3::pfn(q); v96p3::ptk(q);
    v96p3::Cb::stat(q);
  end
endmodule

function automatic real v96_unit_fn(logic [15:0] q); return real'(q); endfunction
