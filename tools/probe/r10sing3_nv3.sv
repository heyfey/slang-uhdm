module dut(o1, o2, o3, o4);
  typedef struct packed {
      logic [5:0] third;
  } struct2;

  // o1: port, driven inside a generate block  (== UnpackPort's var3)
  output struct2 o1 [7];
  for (genvar i=0; i<7; i++) begin : g_fill
      assign o1[i] = struct2'(127);
  end

  // o2: port, driven directly at module level
  output struct2 o2 [7];
  assign o2[0] = struct2'(1);

  // o3: port, undriven
  output struct2 o3 [7];

  // n1: NON-port local, driven inside a generate block
  struct2 n1 [7];
  for (genvar j=0; j<7; j++) begin : g_fill2
      assign n1[j] = struct2'(3);
  end

  // n2: NON-port local, driven directly
  struct2 n2 [7];
  assign n2[0] = struct2'(5);

  // n3: NON-port local, undriven
  struct2 n3 [7];

  // o4: port, driven directly with a MEMBER select
  output struct2 o4 [7];
  assign o4[0].third = 6'd7;
endmodule
