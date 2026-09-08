// v217 arm H — A THREE-PACKAGE CYCLE, and four importers.  qa -> qc -> qb -> qa.
// Legal SV; Surelog rc=0 with 0 errors, all three binaries rc=0.
// GOLDEN, and exactly what "compile in DECLARATION ORDER, each import copying
// the imported package's vector AS IT STANDS" predicts:
//   vec[qa] = [qa_v]              (qc was still empty when qa was compiled)
//   vec[qb] = [qa_v, qb_v]
//   vec[qc] = [qa_v, qb_v, qc_v]
//   m3a  = [qa_v, m3a_clk]                       m3b = [qa_v, qb_v, m3b_clk]
//   m3c  = [qa_v, qb_v, qc_v, m3c_clk]           mboth = [qa_v, qa_v, qb_v, mboth_clk]
package qa; import qc::*; int qa_v; endpackage
package qb; import qa::*; int qb_v; endpackage
package qc; import qb::*; int qc_v; endpackage
module m3a; import qa::*; logic m3a_clk; endmodule
module m3b; import qb::*; logic m3b_clk; endmodule
module m3c; import qc::*; logic m3c_clk; endmodule
module mboth; import qa::*; import qb::*; logic mboth_clk; endmodule
