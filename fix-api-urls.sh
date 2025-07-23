#!/bin/bash

# Script to replace all hardcoded localhost:8080 URLs with config-based relative URLs

echo "🔧 Fixing API URLs in Vue components..."

cd yanxi-web

# List of files to update
files=(
  "src/views/teacher/StudentManagement.vue"
  "src/views/teacher/Home.vue"
  "src/views/teacher/ClassView.vue"
  "src/views/teacher/ClassManagement.vue"
  "src/views/teacher/AssignmentManagement.vue"
  "src/views/student/Home.vue"
  "src/views/student/ClassAssignments.vue"
  "src/views/student/AssignmentManagement.vue"
)

# Function to add config import if not present
add_config_import() {
  local file=$1
  if ! grep -q "import config from '@/config'" "$file"; then
    echo "Adding config import to $file"
    # Add import after axios import
    sed -i "/import axios from 'axios'/a import config from '@/config'" "$file"
  fi
}

# Function to replace URLs
replace_urls() {
  local file=$1
  echo "Updating URLs in $file"
  
  # Replace all variations of localhost:8080/api with config.baseUrl
  sed -i "s|'http://localhost:8080/api/|\`\${config.baseUrl}/|g" "$file"
  sed -i 's|"http://localhost:8080/api/|`${config.baseUrl}/|g' "$file"
  sed -i "s|http://localhost:8080/api/|\${config.baseUrl}/|g" "$file"
  
  # Handle template literals that might be split
  sed -i 's|`http://localhost:8080/api/|`${config.baseUrl}/|g' "$file"
}

# Process each file
for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    add_config_import "$file"
    replace_urls "$file"
  else
    echo "⚠️  File not found: $file"
  fi
done

echo "✅ API URL fixes complete!"
echo "🔨 Now run: npm run build && sudo cp -r dist/* /var/www/html/" 