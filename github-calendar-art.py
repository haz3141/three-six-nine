#!/usr/bin/env python3
"""
GitHub Contribution Calendar Art Generator
Creates visual art using GitHub's contribution intensity levels:
- Level 0: No contributions (no green)
- Level 1: 1-3 contributions (lightest green)
- Level 2: 4-6 contributions (light green) 
- Level 3: 7-9 contributions (medium green)
- Level 4: 10+ contributions (darkest green)
"""

import subprocess
import datetime
import os
import sys
from typing import List, Tuple

class GitHubCalendarArt:
    def __init__(self):
        self.repo_path = "."
        self.commit_count = 0
        
    def create_commits_for_level(self, date: datetime.datetime, level: int, message: str):
        """Create the right number of commits to achieve the desired intensity level"""
        if level == 0:
            return  # No commits needed
            
        # GitHub's contribution levels:
        # Level 1: 1-3 commits
        # Level 2: 4-6 commits  
        # Level 3: 7-9 commits
        # Level 4: 10+ commits
        
        if level == 1:
            num_commits = 2  # Middle of 1-3 range
        elif level == 2:
            num_commits = 5  # Middle of 4-6 range
        elif level == 3:
            num_commits = 8  # Middle of 7-9 range
        elif level == 4:
            num_commits = 12  # Above 10+ threshold
        else:
            num_commits = 1
            
        for i in range(num_commits):
            self.create_single_commit(
                date + datetime.timedelta(minutes=i), 
                f"{message} (commit {i+1}/{num_commits})"
            )
    
    def create_single_commit(self, date: datetime.datetime, message: str):
        """Create a single commit on a specific date"""
        # Create a unique file for this commit
        filename = f"art/{date.strftime('%Y%m%d_%H%M%S')}.md"
        os.makedirs("art", exist_ok=True)
        
        with open(filename, 'w') as f:
            f.write(f"# Calendar Art Pixel\n\n")
            f.write(f"Date: {date.strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write(f"Message: {message}\n\n")
            f.write(f"Part of GitHub contribution calendar art\n")
        
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
    
    def create_heart_art(self, start_date: datetime.datetime):
        """Create a heart shape using different intensity levels"""
        print("Creating heart art with intensity levels...")
        
        # Heart pattern with intensity levels (0-4)
        heart_pattern = [
            [0,0,2,2,0,0,2,2,0,0],
            [0,3,4,4,4,4,4,4,3,0],
            [4,4,4,4,4,4,4,4,4,4],
            [4,4,4,4,4,4,4,4,4,4],
            [0,4,4,4,4,4,4,4,4,0],
            [0,0,4,4,4,4,4,4,0,0],
            [0,0,0,4,4,4,4,0,0,0],
            [0,0,0,0,4,4,0,0,0,0],
            [0,0,0,0,0,2,0,0,0,0]
        ]
        
        for row, line in enumerate(heart_pattern):
            for col, intensity in enumerate(line):
                if intensity > 0:
                    commit_date = start_date + datetime.timedelta(days=col, weeks=row)
                    self.create_commits_for_level(
                        commit_date,
                        intensity,
                        f"Heart art pixel ({row},{col}) - Level {intensity}"
                    )
    
    def create_369_art(self, start_date: datetime.datetime):
        """Create 3-6-9 numbers with intensity levels"""
        print("Creating 3-6-9 art with intensity levels...")
        
        # 3-6-9 pattern with intensity levels
        patterns = {
            '3': [
                [4,4,4,4,4,4],
                [0,0,0,0,0,2],
                [4,4,4,4,4,4],
                [0,0,0,0,0,2],
                [4,4,4,4,4,4]
            ],
            '6': [
                [4,4,4,4,4,4],
                [3,0,0,0,0,0],
                [4,4,4,4,4,4],
                [3,0,0,0,0,2],
                [4,4,4,4,4,4]
            ],
            '9': [
                [4,4,4,4,4,4],
                [3,0,0,0,0,2],
                [4,4,4,4,4,4],
                [0,0,0,0,0,2],
                [4,4,4,4,4,4]
            ]
        }
        
        current_date = start_date
        for number, pattern in patterns.items():
            print(f"Creating number {number}...")
            for row, line in enumerate(pattern):
                for col, intensity in enumerate(line):
                    if intensity > 0:
                        commit_date = current_date + datetime.timedelta(days=col, weeks=row)
                        self.create_commits_for_level(
                            commit_date,
                            intensity,
                            f"Number {number} pixel ({row},{col}) - Level {intensity}"
                        )
            # Move to next number position
            current_date += datetime.timedelta(days=8)
    
    def create_vortex_art(self, start_date: datetime.datetime):
        """Create a vortex/spiral with intensity levels"""
        print("Creating vortex art with intensity levels...")
        
        # Create a spiral pattern with varying intensity
        size = 12
        center = size // 2
        
        for radius in range(1, size):
            for angle in range(0, 360, 20):  # Every 20 degrees
                import math
                x = int(center + radius * math.cos(math.radians(angle)))
                y = int(center + radius * math.sin(math.radians(angle)))
                
                if 0 <= x < size and 0 <= y < size:
                    # Intensity decreases from center
                    intensity = max(1, 4 - (radius // 3))
                    
                    commit_date = start_date + datetime.timedelta(days=x, weeks=y)
                    self.create_commits_for_level(
                        commit_date,
                        intensity,
                        f"Vortex pixel ({x},{y}) - Level {intensity}"
                    )
    
    def create_gradient_art(self, start_date: datetime.datetime):
        """Create a gradient pattern showing all intensity levels"""
        print("Creating gradient art...")
        
        # Create a gradient from level 1 to 4
        for week in range(4):
            for day in range(7):
                intensity = week + 1  # 1, 2, 3, 4
                commit_date = start_date + datetime.timedelta(days=day, weeks=week)
                self.create_commits_for_level(
                    commit_date,
                    intensity,
                    f"Gradient pixel week {week+1} day {day+1} - Level {intensity}"
                )
    
    def create_message_art(self, start_date: datetime.datetime, message: str):
        """Create a simple message with intensity levels"""
        print(f"Creating message art: '{message}'...")
        
        # Simple 5x7 font for letters with intensity levels
        font = {
            'H': [
                [4,0,0,0,4],
                [4,0,0,0,4], 
                [4,4,4,4,4],
                [4,0,0,0,4],
                [4,0,0,0,4]
            ],
            'I': [
                [4,4,4,4,4],
                [0,0,3,0,0],
                [0,0,3,0,0],
                [0,0,3,0,0],
                [4,4,4,4,4]
            ],
            ' ': [
                [0,0,0,0,0],
                [0,0,0,0,0],
                [0,0,0,0,0],
                [0,0,0,0,0],
                [0,0,0,0,0]
            ]
        }
        
        current_date = start_date
        for char in message.upper():
            if char in font:
                pattern = font[char]
                for row, line in enumerate(pattern):
                    for col, intensity in enumerate(line):
                        if intensity > 0:
                            commit_date = current_date + datetime.timedelta(days=col, weeks=row)
                            self.create_commits_for_level(
                                commit_date,
                                intensity,
                                f"Letter '{char}' pixel ({row},{col}) - Level {intensity}"
                            )
                # Move to next character
                current_date += datetime.timedelta(days=6)
            else:
                # Skip unknown characters
                current_date += datetime.timedelta(days=6)

def main():
    if len(sys.argv) < 2:
        print("GitHub Contribution Calendar Art Generator")
        print("Usage: python3 github-calendar-art.py <pattern> [start_date]")
        print("")
        print("Patterns:")
        print("  heart    - Create a heart shape with intensity levels")
        print("  369      - Create 3-6-9 numbers with intensity levels")
        print("  vortex   - Create a spiral pattern with intensity levels")
        print("  gradient - Create a gradient showing all intensity levels")
        print("  message  - Create a custom message")
        print("")
        print("Examples:")
        print("  python3 github-calendar-art.py heart 2024-12-01")
        print("  python3 github-calendar-art.py 369 2025-02-01")
        print("  python3 github-calendar-art.py gradient 2025-04-01")
        sys.exit(1)
    
    pattern = sys.argv[1]
    start_date_str = sys.argv[2] if len(sys.argv) > 2 else "2024-12-01"
    
    try:
        start_date = datetime.datetime.strptime(start_date_str, "%Y-%m-%d")
    except ValueError:
        print("Invalid date format. Use YYYY-MM-DD")
        sys.exit(1)
    
    generator = GitHubCalendarArt()
    
    print(f"Creating GitHub calendar art: {pattern}")
    print(f"Starting date: {start_date.strftime('%Y-%m-%d')}")
    print("Intensity levels: 0=none, 1=light, 2=medium, 3=dark, 4=darkest")
    print("=" * 60)
    
    if pattern == "heart":
        generator.create_heart_art(start_date)
    elif pattern == "369":
        generator.create_369_art(start_date)
    elif pattern == "vortex":
        generator.create_vortex_art(start_date)
    elif pattern == "gradient":
        generator.create_gradient_art(start_date)
    elif pattern == "message":
        message = input("Enter message to create: ")
        generator.create_message_art(start_date, message)
    else:
        print(f"Unknown pattern: {pattern}")
        sys.exit(1)
    
    print("=" * 60)
    print(f"Created {generator.commit_count} commits for calendar art!")
    print("Run 'git push' to upload to GitHub and see your art!")
    print("")
    print("The art will appear in your GitHub contribution calendar with")
    print("different shades of green based on the number of commits per day.")

if __name__ == "__main__":
    main()
