// § tfArgQualOutsideWriter176
package q;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module top (input q::e_t s, output logic [3:0] o);
  function automatic logic [3:0] dec(q::e_t x);
    case (x)
      q::A: return 4'd1;
      q::B: return 4'd2;
      default: return 4'd8;
    endcase
  endfunction
  assign o = dec(s);
endmodule
