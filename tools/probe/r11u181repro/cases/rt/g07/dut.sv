// § rootPathFullNameByChain181 — an event trigger through $root (control)
module top; event e; sub u(); endmodule
module sub; initial -> $root.top.e; endmodule
