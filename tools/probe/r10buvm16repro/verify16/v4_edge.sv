// r10vbuvm16 arm v4 — EDGE SHAPES: nested statement blocks, do/while,
// case/if bodies, ref formals, const locals, real/string/enum/typedef vars,
// a parameterised class, a nested class, an iterator (`with`) and a
// deeply-nested new[] inside a foreach inside a named block.
package vpk4;

  int gp4;
  typedef enum {E0, E1} e4_t;

  class pc4 #(int W = 8);
    int pda[];
    extern function void pf(int pf4);
  endclass
  function void pc4::pf(int pf4);
    int pl4;
    pda = new[pf4 + pl4 + W];       // v4_paramclass  (W is a Parameter)
  endfunction

  class outer4;
    int oda[];
    class inner4;
      int ida[];
      function void inf(int if4);
        int il4;
        ida = new[if4 + il4];       // v4_nestedclass (in-body)
      endfunction
    endclass
    extern function void onf(int of4);
  endclass
  function void outer4::onf(int of4);
    int ol4;
    oda = new[of4 + ol4];           // v4_outerclass
  endfunction

  class k4;
    int kda[];
    int kq[$];
    int kfix[4];
    extern function void kref(ref int rf4);
    extern function void kconst();
    extern function void kkinds();
    extern function void kctrl(int cf4);
    extern function void kdeep();
    extern function void kiter();
    extern function void kdowhile();
  endclass

  function void k4::kref(ref int rf4);
    kda = new[rf4];                 // v4_ref_formal
  endfunction

  function void k4::kconst();
    const int c4 = 5;
    kda = new[c4];                  // v4_const_local
  endfunction

  function void k4::kkinds();
    byte b4; shortint s4; longint l4; bit [7:0] v4; e4_t en4;
    kda = new[b4 + s4 + l4 + v4 + int'(en4)];   // v4_kinds
  endfunction

  function void k4::kctrl(int cf4);
    int cl4;
    if (cf4 > 0) begin
      int if4;
      kda = new[if4 + cl4];         // v4_if_body
    end
    case (cf4)
      0: begin int ca4; kda = new[ca4]; end   // v4_case_body
      default: kda = new[cl4];                // v4_case_default
    endcase
    while (cf4 > 0) begin
      int wl4;
      kda = new[wl4];               // v4_while_body
      cf4--;
    end
  endfunction

  function void k4::kdeep();
    begin : nb4
      int d1;
      begin
        int d2;
        foreach (kfix[fi4]) begin : nb5
          int d3;
          kda = new[d1 + d2 + d3 + fi4];  // v4_deepnest
        end
      end
    end
  endfunction

  function void k4::kiter();
    int it4;
    kda = new[kq.sum() with (item + it4)];  // v4_iterator
  endfunction

  function void k4::kdowhile();
    int dw4;
    do begin
      int dl4;
      kda = new[dw4 + dl4];         // v4_dowhile
    end while (dw4 > 0);
  endfunction

endpackage
