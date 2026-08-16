// r10earl48 VERIFIER — the empty item in the OTHER two positions.
//   y1  `;` AFTER the if-generate item (is it "another member", dropped?)
//   y2  the PROMOTED block contains an if-generate and a trailing `;`
//   y3  the PROMOTED block contains ONLY `;` (the R1 emptiness fence's edge)
module y1 ();
  wire a;
  if (0) begin : y1_t
    wire t;
  end else begin : y1_e
    if (1) begin : y1_c
      wire c;
      assign c = 1'b0;
    end
    ;
  end
endmodule

module y3 ();
  wire a3;
  if (0) begin : y3_t
    wire t;
  end else begin : y3_e
    if (1) begin : y3_c
      ;
    end
  end
endmodule
