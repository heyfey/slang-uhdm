// r10buvm16 — THE HOME / SHAPE COUNTER-WITNESS ARM.
//
// § newArrayArgNoBind16's gate has TWO halves and each needs its own witness:
//   * the SYMBOL half — is the name subroutine-scope?  Cells r10-r13 vary the
//     size EXPRESSION SHAPE (bit-select, conditional, system call, string
//     method) over the same subroutine-scope local.
//   * the HOME half — a class declared INSIDE A MODULE (cells r20-r23) and a
//     `$unit`-scope function (cells r30-r31) are the two homes a1 and a2 do not
//     cover, and the MODULE function / MODULE initial cells (r40-r43) are the
//     ones the law must leave alone.
module top3_16;

   int mv3_16 = 5;
   int marr3_16[4];
   int mdyn3_16[];

   class e16;                            // a class whose HOME IS A MODULE
      int eprop16;
      int edyn16[];
      function void em16(int ef16);
         int eloc16;
         int earr16[4];
         eloc16 = 1;
         edyn16 = new[eloc16];           // r20 module-class in-body: local
         edyn16 = new[ef16];             // r21 module-class in-body: formal
         edyn16 = new[eprop16];          // r22 module-class in-body: property
         edyn16 = new[mv3_16];           // r23 module-class in-body: module var
      endfunction
      extern function void eo16(int eg16);
   endclass

   function void e16::eo16(int eg16);
      int eoloc16;
      eoloc16 = 1;
      edyn16 = new[eoloc16];             // r24 module-class OOB: local
      edyn16 = new[eg16];                // r25 module-class OOB: formal
   endfunction

   function automatic void mf3_16(int r16);
      int rloc16;
      int rarr16[4];
      int rdyn16[];
      rloc16 = 1;
      rdyn16 = new[rloc16];              // r40 MODULE fn: local
      rdyn16 = new[r16];                 // r41 MODULE fn: formal
      rdyn16 = new[rarr16[rloc16]];      // r42 MODULE fn: bit-select of a local
      rdyn16 = new[mv3_16];              // r43 MODULE fn: module var
   endfunction

   initial begin
      int iloc16;
      iloc16 = 1;
      mdyn3_16 = new[iloc16];            // r44 MODULE initial: block local
      mdyn3_16 = new[marr3_16[iloc16]];  // r45 MODULE initial: bit-select
   end
endmodule

package r16;
   int rpkgv16 = 2;
   class f16;
      int fdyn16[];
      extern function void fo16(int fg16, string fs16);
   endclass

   function void f16::fo16(int fg16, string fs16);
      int floc16;
      int farr16[4];
      floc16 = 1;
      fdyn16 = new[farr16[floc16]];      // r10 OOB: BIT-SELECT of a local
      fdyn16 = new[floc16 ? fg16 : 1];   // r11 OOB: CONDITIONAL over local+formal
      fdyn16 = new[$bits(floc16)];       // r12 OOB: SYSTEM call over a local
      fdyn16 = new[fs16.len()];          // r13 OOB: STRING method on a formal
      fdyn16 = new[rpkgv16];             // r14 OOB: package var (control)
   endfunction
endpackage
