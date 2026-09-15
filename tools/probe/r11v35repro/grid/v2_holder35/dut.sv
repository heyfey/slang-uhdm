// v2_holder35 — THE HOLDER axis, independently written: package, interface,
// class, function body, generate block, $unit, plus a non-ANSI module body
// parameter and a union default.
package pkv35;
  localparam int PW = 9;
  localparam type pkt_t = struct packed {
    logic [PW-1:0] a;
    logic [PW*2-1:0] b;
  };
  pkt_t pkv;
endpackage

// $unit-scope type parameter default is not legal SV; a $unit TYPEDEF is the
// control for that holder.
typedef struct packed { logic [pkv35::PW-1:0] ua; } unit35_t;

interface ifv35 #(parameter int IW = 6) ();
  localparam type ift_t = struct packed {
    logic [IW-1:0] a;
  };
  ift_t ifv;
endinterface

class cls35 #(parameter type CT = struct packed { logic [pkv35::PW-1:0] ca; });
  CT cv;
endclass

module v2_holder35 (input logic clk);
  localparam int MW = 10;
  unit35_t uvar;
  ifv35 #(.IW(4)) u_if ();

  // non-ANSI module body type parameter with an anonymous union default
  localparam type uni_t = union packed {
    logic [MW-1:0] ua;
    logic [MW-1:0] ub;
  };
  uni_t uv;

  // a nested anonymous struct inside the default
  localparam type nest_t = struct packed {
    struct packed { logic [MW-1:0] inner; } n;
    logic [MW/2-1:0] o;
  };
  nest_t nvv;

  for (genvar gi = 0; gi < 2; gi++) begin : gblk
    localparam type gt_t = struct packed { logic [MW-1:0] g; };
    gt_t gv;
    always_comb gv = '0;
  end

  function automatic int f35(input int x);
    localparam type ft_t = struct packed { logic [MW-1:0] fa; };
    ft_t fv;
    fv = '0;
    return x + int'(fv.fa);
  endfunction

  int r;
  always_comb begin
    uv = '0;
    nvv = '0;
    uvar = '0;
    r = f35(1);
  end
endmodule
