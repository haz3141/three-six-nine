#!/usr/bin/env python3
"""
GitHub Contribution Calendar Art Generator
Creates commits on specific dates to form an image in your contribution calendar
"""

import subprocess
import datetime
import os
import sys
from typing import List, Tuple

class CalendarArtGenerator:
    def __init__(self):
        self.repo_path = "."
        self.commit_count = 0
        
    def create_commit(self, date: datetime.datetime, message: str, content: str = None):
        """Create a commit on a specific date"""
        if content is None:
            content = f"Art pixel for {date.strftime('%Y-%m-%d')}"
        
        # Create a unique file for this commit
        filename = f"art/{date.strftime('%Y%m%d_%H%M%S')}.md"
        os.makedirs("art", exist_ok=True)
        
        with open(filename, 'w') as f:
            f.write(f"# Calendar Art Pixel\n\n")
            f.write(f"Date: {date.strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write(f"Message: {message}\n\n")
            f.write(f"{content}\n")
        
        # Stage the file
        subprocess.run(["git", "add", filename], cwd=self.repo_path, check=True)
        
        # Create commit with specific date
        env = os.environ.copy()
        env['GIT_AUTHOR_DATE'] = date.strftime('%Y-%m-%d %H:%M:%S')
        env['GIT_COMMITTER_DATE'] = date.strftime('%Y-%m-%d %H:%M:%S')
        
        subprocess.run([
            "git", "commit", "-m", message
        ], cwd=self.repo_path, env=env, check=True)
        
        self.commit_count += 1
        print(f"Created commit {self.commit_count}: {date.strftime('%Y-%m-%d')} - {message}")
    
    def create_heart_pattern(self, start_date: datetime.datetime):
        """Create a heart shape pattern"""
        # Heart pattern (7x7 grid, scaled up)
        heart_pattern = [
            "  ██  ██  ",
            " █████████ ",
            "███████████",
            "███████████",
            " █████████ ",
            "  ███████  ",
            "   █████   ",
            "    ███    ",
            "     █     "
        ]
        
        print("Creating heart pattern...")
        for row, line in enumerate(heart_pattern):
            for col, char in enumerate(line):
                if char == '█':
                    # Calculate the actual date for this position
                    commit_date = start_date + datetime.timedelta(days=col, weeks=row)
                    self.create_commit(
                        commit_date, 
                        f"Heart pixel ({row},{col})",
                        f"Part of heart pattern - row {row}, col {col}"
                    )
    
    def create_3_6_9_pattern(self, start_date: datetime.datetime):
        """Create a 3-6-9 pattern"""
        print("Creating 3-6-9 pattern...")
        
        # Create the numbers 3, 6, 9 in a grid
        patterns = {
            '3': [
                "██████",
                "     █",
                "██████",
                "     █",
                "██████"
            ],
            '6': [
                "██████",
                "█     ",
                "██████",
                "█    █",
                "██████"
            ],
            '9': [
                "██████",
                "█    █",
                "██████",
                "     █",
                "██████"
            ]
        }
        
        current_date = start_date
        for number, pattern in patterns.items():
            print(f"Creating number {number}...")
            for row, line in enumerate(pattern):
                for col, char in enumerate(line):
                    if char == '█':
                        commit_date = current_date + datetime.timedelta(days=col, weeks=row)
                        self.create_commit(
                            commit_date,
                            f"Number {number} pixel ({row},{col})",
                            f"Part of {number} pattern - row {row}, col {col}"
                        )
            # Move to next number position
            current_date += datetime.timedelta(days=8)
    
    def create_vortex_pattern(self, start_date: datetime.datetime):
        """Create a vortex/spiral pattern"""
        print("Creating vortex pattern...")
        
        # Create a simple spiral pattern
        size = 10
        center = size // 2
        
        for radius in range(1, size):
            for angle in range(0, 360, 15):  # Every 15 degrees
                import math
                x = int(center + radius * math.cos(math.radians(angle)))
                y = int(center + radius * math.sin(math.radians(angle)))
                
                if 0 <= x < size and 0 <= y < size:
                    commit_date = start_date + datetime.timedelta(days=x, weeks=y)
                    self.create_commit(
                        commit_date,
                        f"Vortex pixel ({x},{y})",
                        f"Part of vortex pattern - radius {radius}, angle {angle}°"
                    )
    
    def create_simple_message(self, start_date: datetime.datetime, message: str):
        """Create a simple text message"""
        print(f"Creating message: '{message}'...")
        
        # Simple 5x7 font for letters
        font = {
            'H': [
                "█   █",
                "█   █", 
                "█████",
                "█   █",
                "█   █"
            ],
            'I': [
                "█████",
                "  █  ",
                "  █  ",
                "  █  ",
                "█████"
            ],
            ' ': [
                "     ",
                "     ",
                "     ",
                "     ",
                "     "
            ]
        }
        
        current_date = start_date
        for char in message.upper():
            if char in font:
                pattern = font[char]
                for row, line in enumerate(pattern):
                    for col, pixel in enumerate(line):
                        if pixel == '█':
                            commit_date = current_date + datetime.timedelta(days=col, weeks=row)
                            self.create_commit(
                                commit_date,
                                f"Letter '{char}' pixel ({row},{col})",
                                f"Part of message - letter '{char}', row {row}, col {col}"
                            )
                # Move to next character
                current_date += datetime.timedelta(days=6)
            else:
                # Skip unknown characters
                current_date += datetime.timedelta(days=6)

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 create-calendar-art.py <pattern> [start_date]")
        print("Patterns: heart, 369, vortex, message")
        print("Example: python3 create-calendar-art.py heart 2024-12-01")
        sys.exit(1)
    
    pattern = sys.argv[1]
    start_date_str = sys.argv[2] if len(sys.argv) > 2 else "2024-12-01"
    
    try:
        start_date = datetime.datetime.strptime(start_date_str, "%Y-%m-%d")
    except ValueError:
        print("Invalid date format. Use YYYY-MM-DD")
        sys.exit(1)
    
    generator = CalendarArtGenerator()
    
    print(f"Creating calendar art pattern: {pattern}")
    print(f"Starting date: {start_date.strftime('%Y-%m-%d')}")
    print("=" * 50)
    
    if pattern == "heart":
        generator.create_heart_pattern(start_date)
    elif pattern == "369":
        generator.create_3_6_9_pattern(start_date)
    elif pattern == "vortex":
        generator.create_vortex_pattern(start_date)
    elif pattern == "message":
        message = input("Enter message to create: ")
        generator.create_simple_message(start_date, message)
    else:
        print(f"Unknown pattern: {pattern}")
        sys.exit(1)
    
    print("=" * 50)
    print(f"Created {generator.commit_count} commits for calendar art!")
    print("Run 'git push' to upload to GitHub and see your art!")

if __name__ == "__main__":
    main()
