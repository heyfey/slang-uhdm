#!/usr/bin/env python3
import os, shutil
OUT='/tmp/vrgg10_grid8'
if os.path.isdir(OUT): shutil.rmtree(OUT)
os.makedirs(OUT)
SINKS = open('/tmp/vrgg10_grid/f1__portplain/top.sv').read().split('module top;')[0]
CELLS = {
 # module that is NEVER instantiated -> DEF view only
 'defonly': """
module lonely;
  if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
    sink #(8) u (.i_value(IV));
  end
endmodule
module top; endmodule
""",
 # deep gen nesting
 'deepnest': """
module top;
  if (1) begin : a if (1) begin : b if (1) begin : c if (1) begin : d
    localparam bit [7:0] IV = 8'hab;
    if (1) begin : e sink #(8) u (.i_value(IV)); end
  end end end end
endmodule
""",
 # bind directive whose port connection reads the gen localparam
 'bindport': """
module bsink (input logic [7:0] i_value); endmodule
module top;
  if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
    sink #(8) u (.i_value(8'h0));
  end
  bind sink bsink b0 (.i_value(top.g.IV));
endmodule
""",
 # instance array whose range depends on the localparam
 'arrrange': """
module top;
  if (1) begin : g
    localparam bit [7:0] IV = 8'h03;
    sink #(8) u [IV[1:0]:0] (.i_value(8'h0));
  end
endmodule
""",
 # recursive module instantiation in a gen scope
 'recurse': """
module rec #(parameter int N = 2);
  if (N > 0) begin : g
    localparam bit [7:0] IV = 8'hab;
    rec #(N-1) r ();
    sink #(8) u (.i_value(IV));
  end
endmodule
module top; rec #(3) r0(); endmodule
""",
 # many localparams x many instances (perf / leak)
 'wide': """
module top;
  if (1) begin : g
    localparam bit [7:0] A0 = 8'h01; localparam bit [7:0] A1 = 8'h02;
    localparam bit [7:0] A2 = 8'h03; localparam bit [7:0] A3 = 8'h04;
    sink #(8) u0 (.i_value(A0)); sink #(8) u1 (.i_value(A1));
    sink #(8) u2 (.i_value(8'h0)); sink #(8) u3 (.i_value(A3));
  end
endmodule
""",
 # gen scope inside an interface instantiated in top (interface w/ no module inst)
 'ifacegen2': """
interface myif;
  if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
    wire [7:0] w; assign w = IV;
  end
endinterface
module top; myif ifc(); endmodule
""",
 # localparam read by a port connection on an INTERFACE instance's port
 'ifaceportinst': """
interface pif #(parameter int W = 8) (input logic [7:0] i_value); endinterface
module top;
  if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
    pif #(8) p (.i_value(IV));
  end
endmodule
""",
 # uninstantiated (unknown) module in the gen scope beside the read
 'unknowninst': """
module top;
  if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
    sink #(8) u (.i_value(IV));
  end
endmodule
""",
 # generate for with 8 iterations, each an instance reading its own localparam
 'forwide': """
module top;
  for (genvar i = 0; i < 8; i++) begin : g
    localparam bit [7:0] IV = 8'hab + i[7:0];
    sink #(8) u (.i_value(IV));
  end
endmodule
""",
}
for n,s in CELLS.items():
    d=os.path.join(OUT,n); os.makedirs(d); open(os.path.join(d,'top.sv'),'w').write(SINKS+s)
print('cells=%d'%len(CELLS))
