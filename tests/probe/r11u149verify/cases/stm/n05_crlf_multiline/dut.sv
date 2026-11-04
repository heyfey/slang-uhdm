// § streamOperandBraceSpan140 (CRLF line endings)
module dut(input logic [7:0] a, output logic [7:0] y);
  assign y = { <<
    {
      a
    }
  };
endmodule
