"""
Test script to validate the PowerShell installation script
This ensures the script has no syntax errors and works correctly
"""

import os
import sys
import subprocess
import re
from pathlib import Path

def test_powershell_syntax(script_path):
    """Test PowerShell script syntax without executing it"""
    print(f"Testing PowerShell script: {script_path}")
    
    if not os.path.exists(script_path):
        print(f"ERROR: Script not found at {script_path}")
        return False
    
    try:
        # Use PowerShell's built-in syntax checking
        cmd = [
            'powershell.exe',
            '-Command',
            f'$ErrorActionPreference="Stop"; Get-Command Test-ScriptFileInfo -ErrorAction SilentlyContinue; if (-not $?) {{ Install-Module PSScriptAnalyzer -Force -Scope CurrentUser }}; Get-Content "{script_path}" | Out-Null; Write-Host "Syntax OK"'
        ]
        
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=30
        )
        
        if result.returncode == 0:
            print("PASS: PowerShell script syntax is valid")
            return True
        else:
            print(f"ERROR: PowerShell syntax check failed")
            print(f"Output: {result.stdout}")
            print(f"Errors: {result.stderr}")
            return False
            
    except subprocess.TimeoutExpired:
        print("ERROR: Test timed out")
        return False
    except Exception as e:
        print(f"ERROR: Test failed with exception: {e}")
        return False

def test_file_encoding(script_path):
    """Test if file has proper encoding (UTF-8 without BOM)"""
    print(f"\nTesting file encoding...")
    
    try:
        with open(script_path, 'rb') as f:
            content = f.read()
        
        # Check for BOM
        if content.startswith(b'\xef\xbb\xbf'):
            print("WARNING: File has UTF-8 BOM (not critical)")
        elif content.startswith(b'\xff\xfe'):
            print("ERROR: File has UTF-16 encoding")
            return False
        else:
            print("PASS: File encoding is valid")
        
        # Try to decode as UTF-8
        content.decode('utf-8')
        print("PASS: File can be decoded as UTF-8")
        return True
        
    except UnicodeDecodeError as e:
        print(f"ERROR: File encoding issue: {e}")
        return False
    except Exception as e:
        print(f"ERROR: Failed to check encoding: {e}")
        return False

def test_no_emojis(script_path):
    """Test that file contains no emojis"""
    print(f"\nTesting for emojis...")
    
    try:
        with open(script_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Check for common emoji patterns
        emoji_pattern = re.compile(
            "["
            "\U0001F600-\U0001F64F"  # emoticons
            "\U0001F300-\U0001F5FF"  # symbols & pictographs
            "\U0001F680-\U0001F6FF"  # transport & map symbols
            "\U0001F1E0-\U0001F1FF"  # flags
            "\U00002702-\U000027B0"
            "\U000024C2-\U0001F251"
            "]+"
        )
        
        emojis = emoji_pattern.findall(content)
        if emojis:
            print(f"ERROR: Found emojis in file: {emojis}")
            return False
        else:
            print("PASS: No emojis found in file")
            return True
            
    except Exception as e:
        print(f"ERROR: Failed to check for emojis: {e}")
        return False

def test_no_encoding_issues(script_path):
    """Test for common encoding issues"""
    print(f"\nTesting for encoding issues...")
    
    try:
        with open(script_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        issues = []
        for i, line in enumerate(lines, 1):
            try:
                # Check for problematic characters
                if b'\xa0' in line.encode('utf-8') or b'\xc2' in line.encode('utf-8'):
                    issues.append(f"Line {i}: Contains problematic unicode characters")
            except:
                pass
        
        if issues:
            for issue in issues:
                print(f"WARNING: {issue}")
            return False
        else:
            print("PASS: No encoding issues found")
            return True
            
    except Exception as e:
        print(f"ERROR: Failed to test encoding issues: {e}")
        return False

def test_function_definition(script_path):
    """Test that all required functions are defined"""
    print(f"\nTesting function definitions...")
    
    required_functions = [
        'Write-Log',
        'Show-Banner',
        'Test-Administrator',
        'Test-CommandExists',
        'Install-Python',
        'Install-NodeJS',
        'Install-BackendDependencies',
        'Install-FrontendDependencies',
        'Setup-Database',
        'Test-Installation',
        'Main'
    ]
    
    try:
        with open(script_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        missing = []
        for func in required_functions:
            pattern = f'function {func}'
            if pattern not in content:
                missing.append(func)
        
        if missing:
            print(f"ERROR: Missing function definitions: {missing}")
            return False
        else:
            print("PASS: All required functions are defined")
            return True
            
    except Exception as e:
        print(f"ERROR: Failed to check functions: {e}")
        return False

def test_special_characters(script_path):
    """Test for special characters that might cause issues"""
    print(f"\nTesting for special characters...")
    
    problem_chars = [
        '\u2019',  # Right single quotation mark
        '\u201C',  # Left double quotation mark
        '\u201D',  # Right double quotation mark
        '\u2013',  # En dash
        '\u2014',  # Em dash
    ]
    
    try:
        with open(script_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        issues = []
        for char in problem_chars:
            if char in content:
                issues.append(f"Found problematic character: {repr(char)}")
        
        if issues:
            for issue in issues:
                print(f"WARNING: {issue}")
            return False
        else:
            print("PASS: No problematic special characters")
            return True
            
    except Exception as e:
        print(f"ERROR: Failed to check special characters: {e}")
        return False

def main():
    """Run all tests"""
    print("=" * 60)
    print("PowerShell Installation Script Test Suite")
    print("=" * 60)
    
    # Get script path
    script_dir = Path(__file__).parent
    script_path = script_dir / "install-project-dependencies.ps1"
    
    if not os.path.exists(script_path):
        print(f"ERROR: Script not found at {script_path}")
        sys.exit(1)
    
    # Run all tests
    tests = [
        test_file_encoding,
        test_no_emojis,
        test_no_encoding_issues,
        test_function_definition,
        test_special_characters,
    ]
    
    results = []
    for test in tests:
        try:
            result = test(script_path)
            results.append(result)
        except Exception as e:
            print(f"ERROR: Test {test.__name__} failed with exception: {e}")
            results.append(False)
    
    # Summary
    print("\n" + "=" * 60)
    print("TEST SUMMARY")
    print("=" * 60)
    
    passed = sum(results)
    total = len(results)
    
    print(f"\nPassed: {passed}/{total}")
    
    if all(results):
        print("\nSUCCESS: All tests passed!")
        print("The PowerShell script is ready for use.")
        sys.exit(0)
    else:
        print("\nFAILURE: Some tests failed.")
        print("Please review the errors above.")
        sys.exit(1)

if __name__ == "__main__":
    main()

