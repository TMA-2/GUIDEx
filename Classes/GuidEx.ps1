#region: GUID constructor w/ BE option
<# CSharp GUID class from .NET Core
# ref: ctor https://github.com/dotnet/runtime/blob/main/src/libraries/System.Private.CoreLib/src/System/Guid.cs#L80
// Creates a new guid from a read-only span.
public Guid(ReadOnlySpan<byte> b) {
    if (b.Length != 16)
    {
        // throw new ArgumentException(SR.Format(SR.Arg_GuidArrayCtor, "16"), "b");
        ThrowGuidArrayCtorArgumentException();
    }

    // no [System.Runtime.InteropServices.MemoryMarshal] in .NET Framework
    this = MemoryMarshal.Read<Guid>(b);

    if (!BitConverter.IsLittleEndian)
    {
        // the BinaryPrimitives type doesn't exist in .NET Framework
        _a = BinaryPrimitives.ReverseEndianness(_a);
        _b = BinaryPrimitives.ReverseEndianness(_b);
        _c = BinaryPrimitives.ReverseEndianness(_c);
    }
}
public Guid(ReadOnlySpan<byte> b, bool bigEndian) {
	if (b.Length != 16)
	{
		ThrowGuidArrayCtorArgumentException();
	}

	this = MemoryMarshal.Read<Guid>(b);

	if (BitConverter.IsLittleEndian == bigEndian)
	{
		_a = BinaryPrimitives.ReverseEndianness(_a);
		_b = BinaryPrimitives.ReverseEndianness(_b);
		_c = BinaryPrimitives.ReverseEndianness(_c);
	}
}
#>
<# SECTION: ToByteArray w/ BE option
# ref: https://github.com/dotnet/runtime/blob/main/src/libraries/System.Private.CoreLib/src/System/Guid.cs#L916
public byte[] ToByteArray(bool bigEndian) {
    var g = new byte[16];
    if (BitConverter.IsLittleEndian != bigEndian)
    {
        // .NET Framework doesn't have [System.Runtime.InteropServices.MemoryMarshal]
        MemoryMarshal.TryWrite(g, in this);
    }
    else
    {
        // slower path for Reverse
        Guid guid = new Guid(MemoryMarshal.AsBytes(new ReadOnlySpan<Guid>(in this)), bigEndian);
        MemoryMarshal.TryWrite(g, in guid);
    }
    return g;
}
#>
#endregion: GUID constructor w/ BE option

#region: GuidResult struct stuff
<#
# ref: https://github.com/dotnet/runtime/blob/main/src/libraries/System.Private.CoreLib/src/System/Buffers/Binary/BinaryPrimitives.ReverseEndianness.cs#L128
int _a, short _b, short _c, byte _d – _k;
ReverseEndianness... general types get cast to their unsigned counterparts
# BYTE ... nothing needed, really. the value is just returned unmodified
    byte ReverseEndianness(byte value) => value;
# SHORT => (short)ReverseEndianness((ushort)value);
    return (ushort)((value >> 8) + (value << 8));
# CHAR (uses ushort / uint16)
    (char)ReverseEndianness((ushort)value);
# INT => (int)ReverseEndianness((uint)value);
    return BitOperations.RotateRight(value & 0x00FF00FFu, 8) // xx zz
    + BitOperations.RotateLeft(value & 0xFF00FF00u, 8); // ww yy
# LONG =>
    return ((ulong)ReverseEndianness((uint)value) << 32)
    + ReverseEndianness((uint)(value >> 32));
# NINT (int64 / in32)
    nint_t = System.Int64;
    (nint)ReverseEndianness((nint_t)value);
# NUINT (uint64 / uint32)
    nuint_t = System.UInt64;
    (nuint)ReverseEndianness((nuint_t)value);
# INT128 (only in PS Core anyway, so...)
    return new UInt128(
            ReverseEndianness(value.Lower),
            ReverseEndianness(value.Upper)
        );
#>

# Endianness explanation for uint...
# This takes advantage of the fact that the JIT can detect
# ROL32 / ROR32 patterns and output the correct intrinsic.
# > Input: value = [ ww xx yy zz ]
# First line generates : [ ww xx yy zz ]
#                      & [ 00 FF 00 FF ]
#                      = [ 00 xx 00 zz ]
#             ROR32(8) = [ zz 00 xx 00 ]
#
# Second line generates: [ ww xx yy zz ]
#                      & [ FF 00 FF 00 ]
#                      = [ ww 00 yy 00 ]
#             ROL32(8) = [ 00 yy 00 ww ]
#
#                (sum) = [ zz yy xx ww ]

#endregion: GuidResult struct stuff

# https://learn.microsoft.com/en-us/dotnet/standard/base-types/conversion-tables
# ref: https://github.com/dotnet/runtime/blob/main/src/libraries/System.Private.CoreLib/src/System/Buffers/Binary/BinaryPrimitives.ReverseEndianness.cs
class BinaryPrimitivesEx {
    static [byte] ReverseEndianness([byte]$val) {
        # returned with no necessary conversion
        Return $val
    }
    static [char] ReverseEndianness([char]$val) {
        # ushort
        Return [BinaryPrimitivesEx]::ReverseEndianness([UInt16]$val)
    }
    static [uint32] ReverseEndianness([uint32]$val) {
        $ret = $val -band [uint32]0x00FF00FF -shr 8
        $ret += $val -band [uint32]0xFF00FF00 -shl 8
        # BitOperations.RotateRight(value & 0x00FF00FFu, 8) // xx zz
        # + BitOperations.RotateLeft(value & 0xFF00FF00u, 8); // ww yy
        Return $ret
    }
    static [int32] ReverseEndianness([int32]$val) {
        Return ReverseEndianness([uint32]$val)
    }
    static [UInt16] ReverseEndianness([UInt16]$val) {
        # ushort
        Return [UInt16](($val -shr 8) + ($val -shl 8))
    }
    static [Int16] ReverseEndianness([Int16]$val) {
        # short
        Return ReverseEndianness([UInt16]$val)
    }
    static [UInt64] ReverseEndianness([UInt64]$val) {
        # ulong
        # return ((ulong)ReverseEndianness((uint)value) << 32)
        # + ReverseEndianness((uint)(value >> 32));
        Return [UInt64](($val -shr 32) + ($val -shl 32))
    }
    static [Int64] ReverseEndianness([Int64]$val) {
        Return ReverseEndianness([Int64]$val)
    }
}

# WARN: Cannot inherit from sealed class Guid
class GuidEx {
    hidden [string]$Arg_GuidArrayCtor = 'Byte array for Guid must be exactly {0} bytes long.'
    # internal bytes
    hidden [UInt32]$_a # int32 OR uint32
    hidden [UInt16]$_b # short OR ushort
    hidden [UInt16]$_c # short OR ushort
    hidden [byte]$_d
    hidden [byte]$_e
    hidden [byte]$_f
    hidden [byte]$_g
    hidden [byte]$_h
    hidden [byte]$_i
    hidden [byte]$_j
    hidden [byte]$_k
    #

    # originally readonlyspan[byte]. "ByRef-like types are not supported in PowerShell."
    GuidEx ([byte[]]$b) {
        if ($b.Length -ne 16) {
            $this.ThrowGuidArrayCtorArgumentException()
        }

        [Guid]::new($b)
    }

    GuidEx ([byte[]]$b, [bool]$BigEndian) {
        if ($b.Length -ne 16) {
            $this.ThrowGuidArrayCtorArgumentException()
        }

        # no [System.Runtime.InteropServices.MemoryMarshal] in .NET Framework
        # $this = [System.Runtime.InteropServices.MemoryMarshal]::Read([Guid]$b)

        if (![BitConverter]::IsLittleEndian -eq $BigEndian) {
            # $this = [GuidEx]::new($this.ToByteArray($true))
            $this.Reverse($b)
            # the BinaryPrimitives type doesn't exist in .NET Framework
            $this._a = [BinaryPrimitivesEx]::ReverseEndianness($this._a)
            $this._b = [BinaryPrimitivesEx]::ReverseEndianness($this._b)
            $this._c = [BinaryPrimitivesEx]::ReverseEndianness($this._c)

        } else {
            [GuidEx]::new($b)
        }
    }

    hidden convertGuidParts([byte[]]$b) {
        $b[0..3] | ForEach-Object {$this._a += $_} # 32
        $b[4..5] | ForEach-Object {$this._b += $_} # 16
        $b[6..7] | ForEach-Object {$this._c += $_} # 16

        # 73a1e5ba-90ee-494c-863c-59450fd02ec6
        #
        # [char[]](100..107) # d - k
        for ($i = 0; $i -le 7; $i++) {
            $chr = [char](100 + $i)
            $idx = (8 + $i)
            # $this['_d'] = $b[8] (...) $this['_k'] = $b[15]
            $this["_$chr"] = $b[$idx]
        }
    }

    hidden ThrowGuidArrayCtorArgumentException() {
        throw [ArgumentException]::new(($this.Arg_GuidArrayCtor -f '16'), 'b')
    }

    [byte[]] ToByteArray([bool]$BigEndian) {
        $g = [byte[]]::new(16)

        if ([System.BitConverter]::IsLittleEndian -ne $BigEndian) {
            # no conversion needed
            $g = $this.ToByteArray()
        } else {
            $g = $this.Reverse()
        }
        Return $g
    }

    hidden [void] Reverse() {
        $g = $this.ToByteArray()
        [array]::Reverse($g)

        $this = [GuidEx]$g
    }
}

