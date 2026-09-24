// t9: a parameter-port-list entry that OMITS the keyword (LRM: it inherits the
// previous one) and a `localparam type` with TWO declarators on one keyword.
module dut #(
    localparam type LA = int,
                    LB = byte,
    parameter  type PA = int,
                    PB = byte
) (output logic o);
  localparam type MA = shortint, MB = longint;
  LA a; LB b; PA c; PB d; MA e; MB f;
  assign o = (|{a}) ^ (|{b}) ^ (|{c}) ^ (|{d}) ^ (|{e}) ^ (|{f});
endmodule
