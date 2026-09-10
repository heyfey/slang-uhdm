// r11v4 ADVERSARIAL v10 — the cell face (A) is MOST likely to break: a NAMED
// MODPORT connection whose interface instance is an ARRAY ELEMENT.
// `namedModportPortView9` requires `inst.arrayPath.empty()`, so for an array
// element the gate is TRUE and face (A) CLEARS the stamp.  Does golden keep
// vpiOverriden:1 on an OVERRIDDEN array element reached by a named modport?
package pa;
  typedef struct packed { int unsigned DAT; } bus_t;
  localparam bus_t BDEF = '{DAT: 32};
  localparam bus_t BOVR = '{DAT: 64};
endpackage

interface tif #(parameter int W = 4, parameter pa::bus_t CFG = pa::BDEF);
  localparam int BYT = W * 2;
  logic [W-1:0] d;
  modport mp (input d);
endinterface

module leaf  (tif q);    logic z; assign z = q.d[0]; endmodule
module leafm (tif.mp q); logic z; assign z = q.d[0]; endmodule

module top;
  // OVERRIDDEN interface ARRAY.
  tif #(.W(9), .CFG(pa::BOVR)) arr [1:0] ();
  // OVERRIDDEN scalar, for the same connection forms.
  tif #(.W(9), .CFG(pa::BOVR)) sc ();

  leafm a0 (.q(arr[0].mp));   // named MODPORT into an overridden ARRAY element
  leaf  a1 (.q(arr[1]));      // named plain  into an overridden ARRAY element
  leafm a2 (arr[0].mp);       // positional modport, array element
  leafm a3 (.q(sc.mp));       // named modport, scalar  (the known exception)
  leaf  a4 (.q(sc));          // named plain, scalar

  // ...and the same inside a generate block.
  if (1) begin : g
    leafm b0 (.q(arr[1].mp));
    leaf  b1 (.q(arr[0]));
  end
endmodule
