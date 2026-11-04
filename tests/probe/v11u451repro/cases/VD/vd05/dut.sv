// § diamondImportListsPerPath451
package p0; int v0; parameter int P0 = 0; endpackage
package l1; import p0::*; int vl1; endpackage
package r1; import p0::*; int vr1; endpackage
package p1; import l1::*; import r1::*; int v1; endpackage
package l2; import p1::*; int vl2; endpackage
package r2; import p1::*; int vr2; endpackage
package p2; import l2::*; import r2::*; int v2; endpackage
package l3; import p2::*; int vl3; endpackage
package r3; import p2::*; int vr3; endpackage
package p3; import l3::*; import r3::*; int v3; endpackage
package l4; import p3::*; int vl4; endpackage
package r4; import p3::*; int vr4; endpackage
package p4; import l4::*; import r4::*; int v4; endpackage
package l5; import p4::*; int vl5; endpackage
package r5; import p4::*; int vr5; endpackage
package p5; import l5::*; import r5::*; int v5; endpackage
module top; import p5::*; initial v5 = 1; endmodule
