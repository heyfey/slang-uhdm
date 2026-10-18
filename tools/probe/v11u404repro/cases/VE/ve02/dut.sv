// § unknownModEmptyNamedConnPort404
module child (input x, output y);
  wire q;
  nosuch s (.a(x), .b(), .q, .*);
  nosuch t (.*);
  nosuch2 u (x, , y);
endmodule
module top; endmodule
