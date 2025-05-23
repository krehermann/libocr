// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../OCR3BLSAttestationVerifier.sol";

/// @title Demonstration contract showcasing the new BLS signature verification library for OCR
/// @dev In this example contract, the verification library is compiled into the contract and called directly via the
///      exposed verification function from the base contract.
/// @dev !!! CAUTION !!!
///      This demonstration contract only showcases a subset of the required features needed for a secure
///      implementation. For example, it does not provide access control for the setConfig(...) function used to
///      initialize the verification keys. As such, the demonstration contract - by itself - is NOT secure.
contract DemoBLSAttestationVerifier is OCR3BLSAttestationVerifier {
    // A block of storage variables used on the main contract path.
    // To be retrieved via a single SLOAD instruction.
    HotVars s_hotVars;

    struct HotVars {
        uint32 configVersion;
        uint8 n; // total number of oracles
        uint8 f; // maximum number of faulty/dishonest oracles the protocol can tolerate while still working correctly
    }

    function setConfig(uint32 configVersion, uint8 n, uint8 f, bytes calldata keys) external {
        s_hotVars = HotVars({configVersion: configVersion, n: n, f: f});
        _setVerificationKeys(n, keys);
    }

    // We may want to load configDigest from storage instead.
    function transmit(bytes32 configDigest, uint64 seqNr, bytes memory report, bytes calldata attestation) external {
        // Load s_hotVars once here and then only use hotVars to avoid repeated storage access.
        HotVars memory hotVars = s_hotVars;

        // Invoke the attestation verification library.
        // The call reverts if the given attestation for the report is invalid.
        _verifyAttestation(configDigest, seqNr, hotVars.n, hotVars.f, report, attestation);

        // Update the hotVars in storage. Should be done only when they have been modified.
        // Here to silence the warning regarding 'function state mutability'.
        s_hotVars = hotVars;
    }
}
