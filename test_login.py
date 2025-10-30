#!/usr/bin/env python3
"""
Test script to verify backend login functionality
"""
import requests
import json

API_URL = "http://localhost:8000"

def test_login(email, password):
    """Test login functionality"""
    print(f"\n{'='*60}")
    print(f"Testing login with: {email}")
    print(f"{'='*60}\n")
    
    try:
        response = requests.post(
            f"{API_URL}/api/auth/login/",
            json={"email": email, "password": password},
            headers={"Content-Type": "application/json"},
            timeout=5
        )
        
        if response.status_code == 200:
            data = response.json()
            print("[OK] Login successful!")
            print(f"  User: {data['user']['username']} ({data['user']['email']})")
            print(f"  Role: {data['user']['role']}")
            print(f"  Access Token: {data['access'][:50]}...")
            print(f"  Refresh Token: {data['refresh'][:50]}...")
            return True
        else:
            print(f"[FAIL] Login failed: {response.status_code}")
            print(f"  Error: {response.text}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("[ERROR] Cannot connect to backend server")
        print("  Make sure Django server is running on port 8000")
        return False
    except Exception as e:
        print(f"[ERROR] {str(e)}")
        return False

if __name__ == "__main__":
    print("\n" + "="*60)
    print("BACKEND LOGIN TEST")
    print("="*60)
    
    test_accounts = [
        ("superuser@example.com", "superuser"),
        ("admin@example.com", "admin"),
        ("seller@example.com", "seller123"),
        ("buyer@example.com", "buyer123"),
    ]
    
    results = []
    for email, password in test_accounts:
        result = test_login(email, password)
        results.append((email, result))
    
    print("\n" + "="*60)
    print("SUMMARY")
    print("="*60)
    for email, result in results:
        status = "[PASS]" if result else "[FAIL]"
        print(f"{status}: {email}")
    print("="*60)

