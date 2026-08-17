// v88 b5 — FORWARD REFERENCE + qualifier/lifetime + genblock class.
package p5;
  const string c5 = "C5";
  int          n5 = 5;
  class k5;
    string s; int i;
    function void inb_fwd();
      s = c5;              // package const declared AFTER the class
      i = n5;
    endfunction
    static function void inb_static(); endfunction
    virtual function void inb_virt(); s = c5; endfunction
    local function automatic void inb_loc(); s = c5; endfunction
    task inb_task(); s = c5; endtask
    extern function void oob_fwd();
  endclass
  function void k5::oob_fwd(); s = c5; i = n5; endfunction
  class pk5 #(type T = int);
    string s;
    function void inb_par(); s = c5; endfunction
  endclass
endpackage
module topb5;
  import p5::*;
  if (1) begin : g5
    class gc5;
      string s;
      function void inb_gen(); s = c5; endfunction
    endclass
  end
  p5::k5 h; p5::pk5#(int) q;
  initial begin h = new(); q = new(); h.inb_fwd(); h.inb_virt(); h.inb_task(); q.inb_par(); end
endmodule
