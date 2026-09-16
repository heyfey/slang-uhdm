// v11u49 arm v1 — LAW A faces: unpacked package struct param, varied member kinds.
package p;
  typedef struct { logic [7:0] a; logic [15:0] b [3]; } uarr_t;      // unpacked-array member
  typedef struct { logic [7:0] a; logic [3:0][7:0] pk; } upk_t;      // packed-array member
  typedef enum logic [1:0] { E0, E1 } e_t;
  typedef struct { e_t e; logic [7:0] a; } uen_t;                    // enum member
  localparam uarr_t UARR = '{a:8'd1, b:'{16'd2,16'd3,16'd4}};
  localparam upk_t  UPK  = '{a:8'd5, pk:32'hdead_beef};
  localparam uen_t  UEN  = '{e:E1, a:8'd6};
endpackage
module v1 (output logic [31:0] o);
  assign o = p::UARR.a + p::UPK.a + p::UEN.a;
endmodule
