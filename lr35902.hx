package ;

import haxe.io.Bytes;

class LR35902 {
	public var program: Bytes;
	
	public var af(default,set): UInt;
	public var bc(default,set): UInt;
	public var de(default,set): UInt;
	public var hl(default,set): UInt;

	public var pc(default,set): UInt;
	public var sp(default,set): UInt;

	public var ime(default,null) = false;
	public var halt(default,null) = false;

	public var a(get,set): UInt;
	public var b(get,set): UInt;
	public var c(get,set): UInt;
	public var d(get,set): UInt;
	public var e(get,set): UInt;
	public var f(get,set): UInt;
	public var h(get,set): UInt;
	public var l(get,set): UInt;

	public var fz(get,set): Bool;
	public var fn(get,set): Bool;
	public var fh(get,set): Bool;
	public var fc(get,set): Bool;
	
	inline function uint8( v: UInt ) return v & 0xff;
	inline function uint16( v: UInt ) return v & 0xffff;

	inline function set_af( v: UInt ) { var v_ = uint16( v ): af = v_; return v_; }
	inline function set_bc( v: UInt ) { var v_ = uint16( v ): bc = v_; return v_; }
	inline function set_de( v: UInt ) { var v_ = uint16( v ): de = v_; return v_; }
	inline function set_hl( v: UInt ) { var v_ = uint16( v ): hl = v_; return v_; }
	inline function set_pc( v: UInt ) { var v_ = uint16( v ): pc = v_; return v_; }
	inline function set_sp( v: UInt ) { var v_ = uint16( v ): sp = v_; return v_; }

	inline function getLo( hl: UInt ) return 0x00ff & hl;
	inline function getHi( hl: UInt ) return 0xff00 & hl;
	inline function setLo( hl: UInt, v: UInt ) return getHi(hl) + (uint8(v) << 8);
	inline function setHi( hl: UInt, v: UInt ) return getLo(hl) + (uint8(v) << 0);

	public inline function set_a( v: UInt ) { var v_ = uint8(v); af = setHi(af,v_); return v_; }
	public inline function set_b( v: UInt ) { var v_ = uint8(v); bc = setHi(bc,v_); return v_; }
	public inline function set_c( v: UInt ) { var v_ = uint8(v); bc = setLo(bc,v_); return v_; }
	public inline function set_d( v: UInt ) { var v_ = uint8(v); de = setHi(de,v_); return v_; }
	public inline function set_e( v: UInt ) { var v_ = uint8(v); de = setLo(de,v_); return v_; }
	public inline function set_f( v: UInt ) { var v_ = uint8(v); af = setLo(af,v_); return v_; }
	public inline function set_h( v: UInt ) { var v_ = uint8(v); bc = setHi(hl,v_); return v_; }
	public inline function set_l( v: UInt ) { var v_ = uint8(v); bc = setLo(hl,v_); return v_; }

	public inline function get_a() return getHi(af);
	public inline function get_b() return getHi(bc);
	public inline function get_c() return getLo(bc);
	public inline function get_d() return getHi(de);
	public inline function get_e() return getLo(de);
	public inline function get_f() return getLo(af);
	public inline function get_h() return getHi(hl);
	public inline function get_l() return getLo(hl);

	public inline function get_fz() return f & 0x80 == 1;
	public inline function get_fn() return f & 0x40 == 1;
	public inline function get_fh() return f & 0x20 == 1;
	public inline function get_ff() return f & 0x10 == 1;
	
	public inline function set_fz( v: Bool ) { af = v ? af | 0x80 : af & ~0x80; return v; } 
	public inline function set_fn( v: Bool ) { af = v ? af | 0x40 : af & ~0x40; return v; } 
	public inline function set_fh( v: Bool ) { af = v ? af | 0x20 : af & ~0x20; return v; } 
	public inline function set_fc( v: Bool ) { af = v ? af | 0x10 : af & ~0x10; return v; } 

	public function new( ) {
		this.pc = 0;
		this.sp = 0;
	}

	inline function cycles( v: Int ) {}

	public function run() {
		while ( !halt ) {
			pc += switch ( program.get( pc )) {
				case 0x00: cycles(4); 1; 
				case 0x10: halt = true; cycles(4); 2;
				case 0x76: if ( ime ) halt = true; cycles(4); 1;
				case 0xf3: ime = false; cycles(4); 1;
				case 0xfb: ime = true; cycles(4); 1;

				case 0x18: jmpSign( true );
				case 0x20: jmpSign( !fz );
				case 0x30: jmpSign( !fc );
				case 0x28: jmpSign( fz );
				case 0x38: jmpSign( fc );

				case 0xc3: jmp( true );
				case 0xc2: jmp( !fz );
				case 0xd2: jmp( !fc );
				case 0xca: jmp( fz );
				case 0xda: jmp( fc );

				case 0xc9: call( true );
				case 0xc4: call( !fz );
				case 0xd4: call( !fc );
				case 0xcc: call( fz );
				case 0xdc: call( fc );

				case 0xc9: cycles(16); ret( true );
				case 0xd9: ime = true; cycles(16); ret(true);
				case 0xc0: ret( !fz );
				case 0xd0: ret( !fc );
				case 0xc8: ret( fz );
				case 0xd8: ret( fc );

				case 0x01: dc = program.getUInt16( pc+1 ); cycles(16); 3;
				case 0x02: bc = a; cycles(8); 1;
				case 0x03: bc += 1; cycles(8); 1;
				case 0x04: b += 1; fz = b == 0; fn = false; fh = fz; cycles(4); 1;
				case 0x05: b -= 1; fz = b == 0; fn = true; fh = fz; cycles(4); 1;
				case 0x06: b = program.get( pc+1 ); cycles(8); 2;
				case 0x07: 
			}		
		}
	}	
}
