// § defPkgStructParamMemberNames154
package p; typedef struct { int unsigned DLY; } hsk_t; typedef struct { hsk_t HSK; } cfg_t; localparam cfg_t CFG_DEF = '{HSK: '{DLY: 1}}; endpackage
interface tif #(parameter p::cfg_t CFG = p::CFG_DEF); logic [7:0] sig; endinterface
module top(output logic [7:0] o); tif t(); assign o = t.sig; endmodule
