# Raspberry Pi Cluster Hosting Guide for TierNerd

This document outlines how to host the TierNerd application using a Raspberry Pi cluster, covering hardware requirements, setup, performance considerations, and maintenance.

## Hardware Requirements

### Base Configuration
- **Compute Units**: 3-4 Raspberry Pi 4 (8GB RAM) units
- **Storage**: USB 3.0 external SSDs (min. 256GB each, preferably SanDisk Extreme or Samsung T5/T7)
- **Network**: Gigabit Ethernet switch with sufficient ports
- **Power**: Reliable power supply with surge protection and UPS backup
- **Cooling**: Active cooling solution (fans and heatsinks) for each Pi

### Optional Upgrades
- **Pi Models**: Raspberry Pi 5 offers approximately 3x better performance
- **RAM**: 8GB is recommended, but 4GB is workable with optimized configurations
- **Storage**: NVMe drives via USB 3.0 adapters provide best performance

## Software Configuration

### Operating System
- Ubuntu Server 22.04 LTS (64-bit) is recommended for production use
- Ensure regular security updates with automated maintenance windows

### Database (PostgreSQL)
- Configuration optimizations for Pi:
  ```
  shared_buffers = 1GB  # For 8GB RAM Pi
  work_mem = 32MB
  maintenance_work_mem = 256MB
  effective_cache_size = 3GB
  max_parallel_workers_per_gather = 4
  random_page_cost = 1.1  # When using SSD
  ```
- Use external SSD mounted at `/var/lib/postgresql`
- Configure regular backups to a separate storage device

### FastAPI Backend
- Use Uvicorn with ASGI in production
- Configure with appropriate worker count (typically number of cores - 1)
- Ensure async endpoints for better concurrency handling
- Setup:
  ```bash
  python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 3
  ```

### Load Balancing & High Availability
- Install and configure HAProxy or Nginx for request distribution
- Create round-robin distribution across Pi units
- Implement health checks to handle node failures gracefully

## Deployment Architecture

```
                  ┌─────────────────┐
                  │   Client Apps   │
                  └────────┬────────┘
                           │
                           ▼
                  ┌─────────────────┐
                  │  Load Balancer  │
                  └────────┬────────┘
                           │
            ┌──────────────┴─────────────┐
            │                            │
┌───────────▼──────────┐      ┌──────────▼───────────┐
│  Pi Node 1 (Primary) │      │  Pi Node 2 (Worker)  │
│  - API instance      │      │  - API instance      │
└───────────┬──────────┘      └──────────┬───────────┘
            │                            │
            │         ┌──────────────────┘
            │         │
┌───────────▼─────────▼──┐
│  Pi Node 3 (Database)  │
│  - PostgreSQL          │
└──────────┬─────────────┘
           │
┌──────────▼─────────────┐
│   Backup Pi Node 4     │
│   (Failover)           │
└────────────────────────┘
```

## Security Considerations

### System Security
- Change default passwords immediately
- Create custom users with appropriate permissions
- Implement SSH key-based authentication only
- Configure fail2ban for intrusion detection
- Enable and configure firewall (ufw) 
- Disable unnecessary services

### Data Security
- Implement regular database backups
- Consider encrypting sensitive data at rest
- Ensure secure communication with TLS

## Performance Expectations

Based on benchmarks:

### Database Performance
- PostgreSQL: ~200+ TPS on Pi 4 with external SSD
- Capable of handling ~17 million transactions per day
- Database load times significantly faster with SSD (95% improvement)

### API Performance
- FastAPI provides excellent performance on Pi 4
- Async endpoints allow handling multiple concurrent users
- UV server deployment for optimal throughput

This configuration should support:
- Several hundred concurrent users
- Thousands of lists and items stored in database
- Real-time comparison operations

## Monitoring & Maintenance

### Health Monitoring
- Implement Prometheus for metrics collection
- Configure Grafana dashboards for visualization
- Set up alerts for resource constraints

### Regular Maintenance
- Schedule security updates during low-usage windows
- Monitor disk usage and performance
- Create automated backup verification

### Hardware Watchdogs
- Enable the Raspberry Pi hardware watchdog
- Configure software watchdogs for network connectivity
- Implement service monitoring and auto-restart

## Cost Considerations

### Hardware Costs
Approximate one-time setup costs:
- 4× Raspberry Pi 4 (8GB): ~$400
- 4× SSDs (256GB): ~$200
- Network switch: ~$30
- Power supplies: ~$60
- Cooling solutions: ~$40
- Case/rack: ~$50
- UPS: ~$100

Total hardware cost: ~$880

### Operational Costs
- Electricity: ~$5-10/month (varies by location)
- ISP/network costs: Negligible if using existing infrastructure
- Maintenance: Occasional part replacement (~$100/year estimated)

### Cloud Hosting Comparison

#### AWS Equivalent
An equivalent AWS setup for similar performance would require:
- RDS for PostgreSQL db.t3.small: ~$30-45/month
- 2× EC2 t3.medium instances for API: ~$60-75/month
- Load balancer: ~$20/month
- Data transfer: ~$10-20/month
- Storage (50GB): ~$5-10/month

**Total AWS cost: ~$125-170/month ($1,500-2,040/year)**

#### Google Cloud Platform Equivalent
An equivalent Google Cloud Platform setup would require:
- Cloud SQL for PostgreSQL (db-g1-small): ~$45-55/month
- 2× Compute Engine e2-medium instances: ~$50-60/month
- Load Balancer: ~$18-25/month
- Storage (50GB): ~$10/month
- Data transfer: ~$10-15/month

**Total Google Cloud cost: ~$133-165/month ($1,596-1,980/year)**

### Cost Analysis
- Break-even point vs. AWS: ~5-7 months
- Break-even point vs. Google Cloud: ~6-7 months
- 3-year TCO comparison:
  - Raspberry Pi cluster: ~$1,280 ($880 + $400 operational)
  - AWS: ~$4,500-6,120
  - Google Cloud: ~$4,788-5,940

The Raspberry Pi solution provides ~70-80% cost savings over a 3-year period compared to cloud alternatives.

## Future Scalability

- Add more Pi units to the cluster as user base grows
- Separate database and application servers
- Implement sharding for database if necessary
- Consider separating services into microservices architecture

## Troubleshooting

- Power issues: Check UPS, verify quality power supplies
- Heat-related performance drops: Monitor temperatures, improve cooling
- Network connectivity: Check switch, cables, and network settings
- Database performance: Verify SSD health, optimize query performance
- Slowdowns during high usage: Monitor resource utilization, add more nodes if needed