// § impPaLhsDisjointClone133
package flash_ctrl_pkg;
   typedef struct packed {
      logic phase;
   } data_region_attr_t;
   parameter data_region_attr_t HwDataAttr[1] = '{
      '{
         phase: 1'b1
      }
   };
endpackage : flash_ctrl_pkg
module sel import flash_ctrl_pkg::*; #(parameter int W = 1) (
   input data_region_attr_t region_attrs_i [1],
   output logic x
);
   assign x = region_attrs_i[0].phase;
endmodule
module top(output logic o);
   import flash_ctrl_pkg::*;
   sel u_hw_sel (
      .region_attrs_i(HwDataAttr),
      .x(o)
   );
endmodule
