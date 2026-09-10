// r11v4 ADVERSARIAL v9 — DEFPARAM, an interface ARRAY walked by a generate
// FOR, an interface instantiated INSIDE a generate for, and a port view whose
// receiving module is itself parameterized (fold-scope substitution).
interface tif #(parameter int W = 4, parameter int H = W * 2);
  logic [W-1:0] d;
  modport mp (input d);
endinterface

module leaf  #(parameter int W = 77) (tif q);    logic z; assign z = q.d[0]; endmodule
module leafm #(parameter int W = 77) (tif.mp q); logic z; assign z = q.d[0]; endmodule

module top;
  tif #(.W(9)) u_ov();
  tif arr [1:0] ();
  defparam u_ov.W = 9;               // defparam on an already-overridden param

  leaf  a0 (.q(u_ov));
  leaf  #(.W(5)) a1 (.q(u_ov));      // receiving module has its own W
  leafm a2 (.q(u_ov.mp));

  for (genvar gi = 0; gi < 2; gi++) begin : gl
    tif #(.W(gi + 3)) cg();          // genvar-dependent override
    leaf  b0 (.q(cg));
    leaf  b1 (.q(arr[gi]));          // array element indexed by genvar
    leafm b2 (.q(arr[gi].mp));
  end
endmodule
