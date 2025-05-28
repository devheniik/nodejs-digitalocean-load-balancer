# Node.js Load Balancer Infrastructure

## 🏗️ Infrastructure Overview

This project demonstrates a production-ready load balancer implementation using **DigitalOcean**, **Terraform**, and **Node.js**. The infrastructure is designed to showcase horizontal scaling, high availability, and modern cloud architecture patterns.

### Architecture Components

**Load Balancer Layer**
- DigitalOcean Load Balancer with health checks
- Round-robin traffic distribution
- SSL termination capability
- Geographic load balancing across NYC1 region

**Application Layer**
- Multiple Node.js server instances (horizontally scalable)
- PM2 process management for high availability
- Express.js REST API with comprehensive endpoints
- Server identification for load balancing verification

**Database Layer**
- DigitalOcean Managed PostgreSQL cluster
- Private VPC networking for security
- Automated backups and high availability
- SSL-encrypted connections

**Networking Layer**
- Virtual Private Cloud (VPC) for network isolation
- Private networking between components
- Firewall rules for security hardening
- Public IP assignments for external access

## 🚀 Infrastructure Provisioning

### Terraform Infrastructure as Code

The entire infrastructure is defined using Terraform, enabling:
- **Reproducible deployments** across multiple environments
- **Version control** of infrastructure changes
- **Automated resource provisioning** and destruction
- **State management** for infrastructure consistency

### Resource Provisioning Process

**Phase 1: Network Infrastructure**
- VPC creation with custom CIDR blocks
- Subnet allocation for different tiers
- Internet gateway and routing configuration
- Security group and firewall rule establishment

**Phase 2: Database Infrastructure**
- PostgreSQL cluster provisioning with managed service
- Private network integration for security
- Database user and permissions configuration
- Connection pooling and SSL configuration

**Phase 3: Compute Infrastructure**
- Droplet (server) provisioning with Ubuntu
- Node.js runtime and dependency installation
- Application deployment and PM2 configuration
- Server health monitoring setup

**Phase 4: Load Balancer Configuration**
- Load balancer creation with health check rules
- Backend server registration and health monitoring
- SSL certificate provisioning and configuration
- Traffic routing rule establishment

## 🔄 Load Balancing Architecture

### Distribution Strategy

**Round-Robin Algorithm**
The load balancer implements round-robin distribution, ensuring equal traffic distribution across all healthy backend servers. This approach provides:
- Uniform resource utilization across server instances
- Predictable traffic patterns for capacity planning
- Simple configuration and maintenance
- Effective for homogeneous server environments

**Health Check Mechanism**
Continuous health monitoring ensures traffic only routes to healthy instances:
- **Health Check Interval**: Every 30 seconds
- **Failure Threshold**: 3 consecutive failures trigger removal
- **Recovery Threshold**: 2 consecutive successes restore service
- **Health Check Path**: `/health` endpoint validation

### High Availability Features

**Automatic Failover**
When a server becomes unhealthy, the load balancer automatically:
- Removes the failed server from the active pool
- Redistributes traffic among remaining healthy servers
- Continues health checks for automatic recovery
- Restores service when the server becomes healthy

**Session Persistence**
While this implementation uses stateless design, the infrastructure supports:
- Sticky session configuration for stateful applications
- Cookie-based session affinity
- IP-based session persistence
- Custom header-based routing

## 🌐 API Endpoints and Load Balancing Verification

### Health Monitoring Endpoints

**Load Balancer Health Check**
- **Endpoint**: `GET /health`
- **Purpose**: Verifies application health for load balancer
- **Response**: JSON with server status and timestamp
- **Load Balancer Usage**: Automatic health check target

**Individual Server Information**
- **Endpoint**: `GET /server-info`
- **Purpose**: Displays which server handled the request
- **Response**: Server ID, hostname, and processing timestamp
- **Load Balancing Demo**: Shows traffic distribution across servers

### User Management API

**User Listing**
- **Endpoint**: `GET /api/users`
- **Purpose**: Retrieve all users from shared database
- **Database Integration**: Demonstrates shared data consistency
- **Load Balancing**: Each request may hit different servers

**User Creation**
- **Endpoint**: `POST /api/users`
- **Purpose**: Create new user records
- **Database Writes**: Tests write consistency across load-balanced servers
- **Response**: Includes server ID that processed the request

**Individual User Operations**
- **Endpoint**: `GET /api/users/:id`
- **Endpoint**: `PUT /api/users/:id`
- **Endpoint**: `DELETE /api/users/:id`
- **Purpose**: Full CRUD operations through load balancer
- **Consistency**: Shared database ensures data consistency

### Analytics and Monitoring

**Request Statistics**
- **Endpoint**: `GET /api/stats`
- **Purpose**: Display request counts and server distribution
- **Analytics**: Shows load balancing effectiveness
- **Monitoring**: Request patterns and server utilization

**Request Logging**
- **Database Table**: `requests_log`
- **Tracking**: Every API request logged with server ID
- **Analytics**: Traffic patterns and load distribution analysis
- **Performance**: Response time and throughput metrics

## 🔒 Security Architecture

### Network Security

**VPC Isolation**
- Private network segment for all infrastructure components
- Network isolation from other tenants and public internet
- Internal communication through private IP addresses
- Controlled ingress and egress traffic rules

**Firewall Configuration**
- **Load Balancer**: HTTP (80) and HTTPS (443) from internet
- **Application Servers**: Port 3000 only from load balancer
- **Database**: Port 25060 only from application servers
- **SSH Access**: Port 22 from specific IP ranges only

**Database Security**
- SSL-encrypted connections with certificate validation
- Private network access only (no public endpoint)
- User-based access control with least privilege
- Automated security updates and patches

### Access Control

**Service-to-Service Authentication**
- Load balancer to application server communication
- Application server to database authentication
- API key-based authentication for external services
- Certificate-based SSL/TLS encryption

**Administrative Access**
- SSH key-based authentication for server access
- Terraform service account with minimal permissions
- Database admin access through private networking only
- Infrastructure changes through version-controlled IaC

## 📊 Load Balancing Verification Methods

### Traffic Distribution Testing

**Server Identification Method**
Each API response includes a `server_id` field that identifies which backend server processed the request. By making multiple requests to the same endpoint, you can verify:
- Requests are distributed across different servers
- Load balancing algorithm is functioning correctly
- No single server is handling all traffic
- Failed servers are properly excluded from rotation

**Statistical Analysis**
The `/api/stats` endpoint provides comprehensive metrics:
- Total requests per server instance
- Request distribution percentages
- Server response time averages
- Failed request counts and error rates

### Real-World Load Testing

**Concurrent Request Testing**
Using tools like Apache Bench, curl scripts, or Postman Runner:
- Send 100+ concurrent requests to verify distribution
- Monitor server resource utilization during load
- Verify database connection pooling effectiveness
- Test failover scenarios by stopping server instances

**Database Consistency Verification**
- Create users through different server instances
- Verify all servers see the same data (shared database)
- Test transaction consistency across load-balanced writes
- Validate session-less application design

## 🔧 Infrastructure Management

### Deployment Process

**Infrastructure Deployment**
1. Terraform plan generation and review
2. Infrastructure provisioning via `terraform apply`
3. Automated server configuration and application deployment
4. Load balancer backend registration and health check validation
5. DNS configuration and SSL certificate provisioning

**Application Updates**
- Blue-green deployment capability through load balancer
- Rolling updates with zero downtime
- Health check validation before traffic routing
- Automated rollback on deployment failures

### Monitoring and Observability

**Health Monitoring**
- Load balancer health check dashboard
- Server resource utilization monitoring
- Database performance and connection metrics
- Application response time and error rate tracking

**Logging and Analytics**
- Centralized application logging
- Request tracing across load-balanced servers
- Database query performance monitoring
- Infrastructure resource utilization tracking

### Scaling Operations

**Horizontal Scaling**
- Add new server instances through Terraform configuration
- Automatic load balancer backend registration
- Database connection scaling through connection pooling
- No application downtime during scaling operations

**Vertical Scaling**
- Server resource allocation through Terraform variables
- Database resource scaling through managed service console
- Load balancer capacity adjustment for increased throughput
- Performance optimization through resource right-sizing

## 🧪 Testing and Validation

### Load Balancer Testing Scenarios

**Basic Functionality Testing**
1. Verify health checks are passing for all servers
2. Confirm traffic distribution across available servers
3. Test API functionality through load balancer
4. Validate database connectivity and consistency

**Failure Scenario Testing**
1. Stop one server instance and verify traffic redistribution
2. Simulate database connectivity issues
3. Test load balancer behavior during server startup
4. Validate automatic recovery when servers become healthy

**Performance Testing**
1. Concurrent user simulation with realistic traffic patterns
2. Database performance under load-balanced traffic
3. Network latency impact of load balancer layer
4. Resource utilization optimization and bottleneck identification

### API Testing Through Load Balancer

**Functional Testing**
- All CRUD operations work correctly through load balancer
- Data consistency maintained across multiple servers
- Error handling and response consistency
- Authentication and authorization through load-balanced requests

**Load Distribution Verification**
- Multiple requests to `/server-info` show different server IDs
- Database writes through different servers appear consistently
- Request logging shows balanced distribution in `/api/stats`
- No single server overwhelmed during normal operation

## 📈 Performance Characteristics

### Load Balancer Performance

**Throughput Metrics**
- Concurrent connection handling capacity
- Request processing latency overhead
- SSL termination performance impact
- Geographic routing efficiency

**Availability Metrics**
- Uptime percentage and reliability statistics
- Mean time to recovery (MTTR) for failed components
- Health check responsiveness and accuracy
- Failover time measurements

### Database Performance

**Connection Management**
- Connection pooling efficiency across multiple servers
- Database connection utilization and optimization
- Query performance consistency under load
- Transaction throughput and concurrency handling

**Data Consistency**
- Read-after-write consistency verification
- Transaction isolation and ACID compliance
- Backup and recovery time objectives
- Replication lag and consistency monitoring

## 🔄 Maintenance and Operations

### Routine Maintenance

**Infrastructure Updates**
- Operating system security updates through automation
- Application dependency updates and security patches
- Database maintenance windows and version upgrades
- SSL certificate renewal and management

**Performance Optimization**
- Database query optimization and indexing
- Application performance profiling and optimization
- Load balancer configuration tuning
- Resource utilization analysis and right-sizing

### Disaster Recovery

**Backup Strategy**
- Automated database backups and point-in-time recovery
- Infrastructure configuration backup through version control
- Application deployment artifact management
- Documentation and runbook maintenance

**Recovery Procedures**
- Database restoration and failover procedures
- Server instance replacement and reconfiguration
- Load balancer configuration restoration
- Full environment recreation from Terraform configuration

## 🎯 Key Achievements

This infrastructure demonstrates several important concepts:

**Modern Cloud Architecture**
- Infrastructure as Code with full automation
- Microservices-ready foundation with load balancing
- Security-first design with network isolation
- Scalable and resilient system architecture

**Load Balancing Mastery**
- Production-ready load balancer implementation
- Health checking and automatic failover
- Traffic distribution verification and monitoring
- High availability and disaster recovery capabilities

**DevOps Best Practices**
- Version-controlled infrastructure management
- Automated deployment and configuration management
- Comprehensive monitoring and observability
- Security hardening and access control

The project serves as a blueprint for building scalable, resilient web applications with proper load balancing, database management, and infrastructure automation in modern cloud environments.