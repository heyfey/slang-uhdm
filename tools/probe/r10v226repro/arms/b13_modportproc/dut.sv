// v226 b13 — an uninstantiated interface with PORTS, MODPORTS, a clocking
// block and a process that reads all three, plus a DPI import used from the
// process (§216's neighbourhood).
interface bmp_if (input logic clk, inout wire bus);
  import "DPI-C" function int dpi_add(input int a);
  export "DPI-C" function ef;
  logic a, b;
  int   n;
  clocking cb @(posedge clk);
    input  a;
    output b;
  endclocking
  modport mp (input a, output b, clocking cb);
  function automatic void ef(); n = 0; endfunction

  initial begin
    n = dpi_add(1);
    b = a;
  end
  always @(cb) n = n + 1;
  always_comb a = bus;
endinterface
